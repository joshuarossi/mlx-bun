import host.ts.Source
import host.load.Header
namespace Host.Load.Data
open Host.Ts
set_option maxRecDepth 100000

/-! # The load route's data, verbatim

Generated and checked by `host/load/DataBinding.ts` against the model
directory and the repository: the files the route reads, each shard's
JSON header with its length and the file's size, the directory listing,
and the weight tables `mlx_load_safetensors` answers from, each proved
equal to `stHeader` of its shard's header text. -/

def modelDir : String := "/Users/joshrossi/.cache/huggingface/hub/models--mlx-bun--Qwen3.8-27B-Trellis-3.2bpw/snapshots/cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d"

/-- Verbatim `config.json` of the model directory. -/
def config : String := r#"{
  "architectures": [
    "Qwen3_5ForConditionalGeneration"
  ],
  "image_token_id": 248056,
  "language_model_only": false,
  "model_type": "qwen3_5",
  "text_config": {
    "attention_bias": false,
    "attention_dropout": 0,
    "attn_output_gate": true,
    "bos_token_id": 248044,
    "dtype": "bfloat16",
    "eos_token_id": 248044,
    "full_attention_interval": 4,
    "head_dim": 256,
    "hidden_act": "silu",
    "hidden_size": 5120,
    "initializer_range": 0.02,
    "intermediate_size": 17408,
    "layer_types": [
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention",
      "linear_attention",
      "linear_attention",
      "linear_attention",
      "full_attention"
    ],
    "linear_conv_kernel_dim": 4,
    "linear_key_head_dim": 128,
    "linear_num_key_heads": 16,
    "linear_num_value_heads": 48,
    "linear_value_head_dim": 128,
    "mamba_ssm_dtype": "float32",
    "max_position_embeddings": 262144,
    "model_type": "qwen3_5_text",
    "mtp_num_hidden_layers": 1,
    "mtp_use_dedicated_embeddings": false,
    "num_attention_heads": 24,
    "num_hidden_layers": 64,
    "num_key_value_heads": 4,
    "output_gate_type": "swish",
    "pad_token_id": null,
    "partial_rotary_factor": 0.25,
    "rms_norm_eps": 0.000001,
    "rope_parameters": {
      "mrope_interleaved": true,
      "mrope_section": [
        11,
        11,
        10
      ],
      "partial_rotary_factor": 0.25,
      "rope_theta": 10000000,
      "rope_type": "default"
    },
    "tie_word_embeddings": false,
    "use_cache": true,
    "vocab_size": 248320
  },
  "tie_word_embeddings": false,
  "transformers_version": "5.8.0.dev0",
  "video_token_id": 248057,
  "vision_config": {
    "deepstack_visual_indexes": [],
    "depth": 27,
    "hidden_act": "gelu_pytorch_tanh",
    "hidden_size": 1152,
    "in_channels": 3,
    "initializer_range": 0.02,
    "intermediate_size": 4304,
    "model_type": "qwen3_5",
    "num_heads": 16,
    "num_position_embeddings": 2304,
    "out_hidden_size": 5120,
    "patch_size": 16,
    "spatial_merge_size": 2,
    "temporal_patch_size": 2
  },
  "vision_end_token_id": 248054,
  "vision_start_token_id": 248053,
  "quantization": {
    "group_size": 64,
    "bits": 3,
    "mode": "affine",
    "lm_head": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.lm_head": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.embed_tokens": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.embed_tokens": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.0.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.0.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.0.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.0.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.0.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.1.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.1.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.1.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.1.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.1.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.1.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.2.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.2.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.2.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.2.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.2.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.2.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.3.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.3.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.3.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.3.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.visual.blocks.0.attn.proj": false,
    "model.visual.blocks.0.attn.qkv": false,
    "model.visual.blocks.0.mlp.linear_fc1": false,
    "model.visual.blocks.1.attn.proj": false,
    "model.visual.blocks.1.attn.qkv": false,
    "model.visual.blocks.1.mlp.linear_fc1": false,
    "model.visual.blocks.10.attn.proj": false,
    "model.visual.blocks.10.attn.qkv": false,
    "model.visual.blocks.10.mlp.linear_fc1": false,
    "model.visual.blocks.11.attn.proj": false,
    "model.visual.blocks.11.attn.qkv": false,
    "model.visual.blocks.11.mlp.linear_fc1": false,
    "model.visual.blocks.12.attn.proj": false,
    "model.visual.blocks.12.attn.qkv": false,
    "model.visual.blocks.12.mlp.linear_fc1": false,
    "model.visual.blocks.13.attn.proj": false,
    "model.visual.blocks.13.attn.qkv": false,
    "model.visual.blocks.13.mlp.linear_fc1": false,
    "model.visual.blocks.14.attn.proj": false,
    "model.visual.blocks.14.attn.qkv": false,
    "model.visual.blocks.14.mlp.linear_fc1": false,
    "model.visual.blocks.15.attn.proj": false,
    "model.visual.blocks.15.attn.qkv": false,
    "model.visual.blocks.15.mlp.linear_fc1": false,
    "model.visual.blocks.16.attn.proj": false,
    "model.visual.blocks.16.attn.qkv": false,
    "model.visual.blocks.16.mlp.linear_fc1": false,
    "model.visual.blocks.17.attn.proj": false,
    "model.visual.blocks.17.attn.qkv": false,
    "model.visual.blocks.17.mlp.linear_fc1": false,
    "model.visual.blocks.18.attn.proj": false,
    "model.visual.blocks.18.attn.qkv": false,
    "model.visual.blocks.18.mlp.linear_fc1": false,
    "model.visual.blocks.19.attn.proj": false,
    "model.visual.blocks.19.attn.qkv": false,
    "model.visual.blocks.19.mlp.linear_fc1": false,
    "model.visual.blocks.2.attn.proj": false,
    "model.visual.blocks.2.attn.qkv": false,
    "model.visual.blocks.2.mlp.linear_fc1": false,
    "model.visual.blocks.20.attn.proj": false,
    "model.visual.blocks.20.attn.qkv": false,
    "model.visual.blocks.20.mlp.linear_fc1": false,
    "model.visual.blocks.21.attn.proj": false,
    "model.visual.blocks.21.attn.qkv": false,
    "model.visual.blocks.21.mlp.linear_fc1": false,
    "model.visual.blocks.22.attn.proj": false,
    "model.visual.blocks.22.attn.qkv": false,
    "model.visual.blocks.22.mlp.linear_fc1": false,
    "model.visual.blocks.23.attn.proj": false,
    "model.visual.blocks.23.attn.qkv": false,
    "model.visual.blocks.23.mlp.linear_fc1": false,
    "model.visual.blocks.24.attn.proj": false,
    "model.visual.blocks.24.attn.qkv": false,
    "model.visual.blocks.24.mlp.linear_fc1": false,
    "model.visual.blocks.25.attn.proj": false,
    "model.visual.blocks.25.attn.qkv": false,
    "model.visual.blocks.25.mlp.linear_fc1": false,
    "model.visual.blocks.26.attn.proj": false,
    "model.visual.blocks.26.attn.qkv": false,
    "model.visual.blocks.26.mlp.linear_fc1": false,
    "model.visual.blocks.3.attn.proj": false,
    "model.visual.blocks.3.attn.qkv": false,
    "model.visual.blocks.3.mlp.linear_fc1": false,
    "model.visual.blocks.4.attn.proj": false,
    "model.visual.blocks.4.attn.qkv": false,
    "model.visual.blocks.4.mlp.linear_fc1": false,
    "model.visual.blocks.5.attn.proj": false,
    "model.visual.blocks.5.attn.qkv": false,
    "model.visual.blocks.5.mlp.linear_fc1": false,
    "model.visual.blocks.6.attn.proj": false,
    "model.visual.blocks.6.attn.qkv": false,
    "model.visual.blocks.6.mlp.linear_fc1": false,
    "model.visual.blocks.7.attn.proj": false,
    "model.visual.blocks.7.attn.qkv": false,
    "model.visual.blocks.7.mlp.linear_fc1": false,
    "model.visual.blocks.8.attn.proj": false,
    "model.visual.blocks.8.attn.qkv": false,
    "model.visual.blocks.8.mlp.linear_fc1": false,
    "model.visual.blocks.9.attn.proj": false,
    "model.visual.blocks.9.attn.qkv": false,
    "model.visual.blocks.9.mlp.linear_fc1": false,
    "model.visual.merger.linear_fc1": false,
    "model.visual.merger.linear_fc2": false,
    "model.visual.pos_embed": false,
    "model.language_model.layers.10.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.10.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.10.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.10.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.10.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.10.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.10.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.10.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.10.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.10.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.11.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.11.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.11.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.11.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.12.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.12.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.12.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.12.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.12.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.12.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.12.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.13.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.13.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.13.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.13.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.13.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.13.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.13.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.13.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.13.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.13.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.14.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.14.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.14.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.14.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.14.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.14.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.14.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.14.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.14.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.14.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.15.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.15.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.15.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.15.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.8.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.8.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.8.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.8.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.8.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.8.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.8.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.9.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.9.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.9.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.9.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.9.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.9.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.9.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.9.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.9.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.9.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.16.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.16.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.16.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.16.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.16.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.16.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.16.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.16.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.16.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.16.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.17.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.17.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.17.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.17.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.17.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.17.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.17.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.17.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.17.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.17.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.18.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.18.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.18.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.18.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.18.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.18.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.18.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.18.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.18.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.18.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.19.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.19.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.19.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.19.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.20.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.20.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.20.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.20.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.20.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.20.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.20.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.21.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.21.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.21.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.21.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.21.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.21.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.21.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.21.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.21.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.21.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.22.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.22.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.22.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.22.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.22.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.22.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.22.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.22.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.22.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.22.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.23.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.23.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.23.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.23.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.24.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.24.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.24.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.24.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.24.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.24.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.24.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.25.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.25.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.25.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.25.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.25.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.25.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.26.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.26.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.26.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.26.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.26.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.26.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.26.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.26.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.26.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.26.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.27.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.27.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.27.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.27.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.28.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.28.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.28.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.28.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.28.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.28.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.28.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.29.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.29.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.29.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.29.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.29.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.29.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.29.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.29.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.29.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.29.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.30.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.30.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.30.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.30.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.30.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.30.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.30.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.30.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.30.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.30.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.31.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.31.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.31.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.31.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.32.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.32.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.32.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.32.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.32.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.32.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.32.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.33.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.33.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.33.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.33.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.33.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.33.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.33.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.33.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.33.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.33.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.34.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.34.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.34.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.34.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.34.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.34.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.34.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.34.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.34.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.34.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.35.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.35.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.35.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.35.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.36.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.36.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.36.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.36.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.36.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.36.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.36.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.37.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.37.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.37.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.37.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.37.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.37.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.37.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.37.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.37.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.37.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.38.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.38.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.38.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.38.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.38.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.38.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.38.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.38.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.38.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.38.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.39.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.39.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.39.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.39.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.4.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.4.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.4.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.4.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.4.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.5.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.5.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.5.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.5.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.5.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.5.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.6.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.6.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.6.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.6.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.6.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.6.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.6.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.6.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.6.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.6.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.7.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.7.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.7.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.7.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.40.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.40.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.40.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.40.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.40.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.40.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.40.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.41.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.41.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.41.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.41.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.41.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.41.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.41.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.41.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.41.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.41.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.42.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.42.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.42.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.42.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.42.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.42.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.42.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.42.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.42.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.42.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.43.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.43.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.43.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.43.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.44.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.44.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.44.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.44.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.44.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.44.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.44.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.45.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.45.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.45.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.45.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.45.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.45.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.45.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.45.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.45.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.45.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.46.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.46.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.46.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.46.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.46.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.46.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.46.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.46.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.46.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.46.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.47.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.47.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.47.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.47.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.48.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.48.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.48.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.48.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.48.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.48.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.48.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.49.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.49.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.49.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.49.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.49.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.49.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.49.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.49.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.49.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.49.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.50.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.50.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.50.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.50.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.50.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.50.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.50.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.50.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.50.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.50.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.51.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.51.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.51.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.51.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.52.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.52.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.52.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.52.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.52.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.52.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.52.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.53.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.53.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.53.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.53.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.53.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.53.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.54.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.54.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.54.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.54.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.54.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.54.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.55.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.55.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.55.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.55.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.56.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.56.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.56.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.56.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.56.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.57.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.57.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.57.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.57.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.57.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.57.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.58.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.58.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.58.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.58.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.58.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.58.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.59.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.59.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.59.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.59.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.60.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.60.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.60.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.60.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.60.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.61.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.61.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.61.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.61.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.61.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.61.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.62.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.62.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.62.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.62.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.62.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.62.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.63.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.63.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.63.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.63.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    }
  },
  "quantization_config": {
    "group_size": 64,
    "bits": 3,
    "mode": "affine",
    "lm_head": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.lm_head": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.embed_tokens": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.embed_tokens": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.0.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.0.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.0.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.0.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.0.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.0.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.0.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.1.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.1.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.1.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.1.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.1.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.1.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.1.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.1.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.2.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.2.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.2.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.2.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.2.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.2.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.2.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.2.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.3.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.3.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.3.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.3.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.3.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.3.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.3.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.visual.blocks.0.attn.proj": false,
    "model.visual.blocks.0.attn.qkv": false,
    "model.visual.blocks.0.mlp.linear_fc1": false,
    "model.visual.blocks.1.attn.proj": false,
    "model.visual.blocks.1.attn.qkv": false,
    "model.visual.blocks.1.mlp.linear_fc1": false,
    "model.visual.blocks.10.attn.proj": false,
    "model.visual.blocks.10.attn.qkv": false,
    "model.visual.blocks.10.mlp.linear_fc1": false,
    "model.visual.blocks.11.attn.proj": false,
    "model.visual.blocks.11.attn.qkv": false,
    "model.visual.blocks.11.mlp.linear_fc1": false,
    "model.visual.blocks.12.attn.proj": false,
    "model.visual.blocks.12.attn.qkv": false,
    "model.visual.blocks.12.mlp.linear_fc1": false,
    "model.visual.blocks.13.attn.proj": false,
    "model.visual.blocks.13.attn.qkv": false,
    "model.visual.blocks.13.mlp.linear_fc1": false,
    "model.visual.blocks.14.attn.proj": false,
    "model.visual.blocks.14.attn.qkv": false,
    "model.visual.blocks.14.mlp.linear_fc1": false,
    "model.visual.blocks.15.attn.proj": false,
    "model.visual.blocks.15.attn.qkv": false,
    "model.visual.blocks.15.mlp.linear_fc1": false,
    "model.visual.blocks.16.attn.proj": false,
    "model.visual.blocks.16.attn.qkv": false,
    "model.visual.blocks.16.mlp.linear_fc1": false,
    "model.visual.blocks.17.attn.proj": false,
    "model.visual.blocks.17.attn.qkv": false,
    "model.visual.blocks.17.mlp.linear_fc1": false,
    "model.visual.blocks.18.attn.proj": false,
    "model.visual.blocks.18.attn.qkv": false,
    "model.visual.blocks.18.mlp.linear_fc1": false,
    "model.visual.blocks.19.attn.proj": false,
    "model.visual.blocks.19.attn.qkv": false,
    "model.visual.blocks.19.mlp.linear_fc1": false,
    "model.visual.blocks.2.attn.proj": false,
    "model.visual.blocks.2.attn.qkv": false,
    "model.visual.blocks.2.mlp.linear_fc1": false,
    "model.visual.blocks.20.attn.proj": false,
    "model.visual.blocks.20.attn.qkv": false,
    "model.visual.blocks.20.mlp.linear_fc1": false,
    "model.visual.blocks.21.attn.proj": false,
    "model.visual.blocks.21.attn.qkv": false,
    "model.visual.blocks.21.mlp.linear_fc1": false,
    "model.visual.blocks.22.attn.proj": false,
    "model.visual.blocks.22.attn.qkv": false,
    "model.visual.blocks.22.mlp.linear_fc1": false,
    "model.visual.blocks.23.attn.proj": false,
    "model.visual.blocks.23.attn.qkv": false,
    "model.visual.blocks.23.mlp.linear_fc1": false,
    "model.visual.blocks.24.attn.proj": false,
    "model.visual.blocks.24.attn.qkv": false,
    "model.visual.blocks.24.mlp.linear_fc1": false,
    "model.visual.blocks.25.attn.proj": false,
    "model.visual.blocks.25.attn.qkv": false,
    "model.visual.blocks.25.mlp.linear_fc1": false,
    "model.visual.blocks.26.attn.proj": false,
    "model.visual.blocks.26.attn.qkv": false,
    "model.visual.blocks.26.mlp.linear_fc1": false,
    "model.visual.blocks.3.attn.proj": false,
    "model.visual.blocks.3.attn.qkv": false,
    "model.visual.blocks.3.mlp.linear_fc1": false,
    "model.visual.blocks.4.attn.proj": false,
    "model.visual.blocks.4.attn.qkv": false,
    "model.visual.blocks.4.mlp.linear_fc1": false,
    "model.visual.blocks.5.attn.proj": false,
    "model.visual.blocks.5.attn.qkv": false,
    "model.visual.blocks.5.mlp.linear_fc1": false,
    "model.visual.blocks.6.attn.proj": false,
    "model.visual.blocks.6.attn.qkv": false,
    "model.visual.blocks.6.mlp.linear_fc1": false,
    "model.visual.blocks.7.attn.proj": false,
    "model.visual.blocks.7.attn.qkv": false,
    "model.visual.blocks.7.mlp.linear_fc1": false,
    "model.visual.blocks.8.attn.proj": false,
    "model.visual.blocks.8.attn.qkv": false,
    "model.visual.blocks.8.mlp.linear_fc1": false,
    "model.visual.blocks.9.attn.proj": false,
    "model.visual.blocks.9.attn.qkv": false,
    "model.visual.blocks.9.mlp.linear_fc1": false,
    "model.visual.merger.linear_fc1": false,
    "model.visual.merger.linear_fc2": false,
    "model.visual.pos_embed": false,
    "model.language_model.layers.10.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.10.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.10.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.10.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.10.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.10.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.10.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.10.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.10.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.10.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.11.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.11.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.11.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.11.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.11.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.11.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.11.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.12.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.12.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.12.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.12.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.12.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.12.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.12.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.12.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.13.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.13.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.13.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.13.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.13.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.13.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.13.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.13.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.13.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.13.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.14.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.14.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.14.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.14.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.14.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.14.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.14.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.14.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.14.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.14.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.15.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.15.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.15.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.15.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.15.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.15.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.15.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.8.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.8.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.8.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.8.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.8.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.8.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.8.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.8.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.9.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.9.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.9.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.9.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.9.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.9.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.9.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.9.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.9.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.9.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.16.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.16.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.16.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.16.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.16.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.16.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.16.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.16.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.16.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.16.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.17.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.17.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.17.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.17.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.17.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.17.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.17.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.17.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.17.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.17.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.18.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.18.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.18.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.18.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.18.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.18.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.18.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.18.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.18.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.18.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.19.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.19.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.19.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.19.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.19.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.19.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.19.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.20.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.20.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.20.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.20.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.20.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.20.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.20.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.20.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.21.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.21.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.21.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.21.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.21.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.21.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.21.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.21.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.21.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.21.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.22.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.22.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.22.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.22.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.22.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.22.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.22.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.22.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.22.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.22.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.23.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.23.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.23.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.23.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.23.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.23.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.23.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.24.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.24.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.24.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.24.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.24.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.24.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.24.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.24.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.25.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.25.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.25.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.25.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.25.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.25.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.25.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.25.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.26.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.26.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.26.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.26.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.26.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.26.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.26.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.26.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.26.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.26.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.27.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.27.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.27.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.27.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.27.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.27.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.27.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.28.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.28.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.28.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.28.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.28.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.28.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.28.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.28.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.29.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.29.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.29.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.29.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.29.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.29.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.29.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.29.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.29.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.29.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.30.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.30.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.30.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.30.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.30.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.30.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.30.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.30.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.30.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.30.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.31.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.31.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.31.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.31.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.31.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.31.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.31.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.32.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.32.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.32.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.32.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.32.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.32.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.32.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.32.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.33.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.33.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.33.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.33.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.33.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.33.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.33.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.33.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.33.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.33.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.34.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.34.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.34.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.34.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.34.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.34.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.34.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.34.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.34.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.34.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.35.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.35.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.35.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.35.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.35.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.35.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.35.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.36.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.36.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.36.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.36.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.36.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.36.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.36.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.36.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.37.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.37.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.37.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.37.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.37.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.37.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.37.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.37.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.37.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.37.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.38.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.38.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.38.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.38.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.38.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.38.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.38.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.38.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.38.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.38.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.39.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.39.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.39.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.39.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.39.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.39.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.39.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.4.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.4.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.4.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.4.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.4.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.4.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.4.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.5.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.5.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.5.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.5.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.5.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.5.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.5.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.5.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.6.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.6.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.6.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.6.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.6.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.6.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.6.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.6.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.6.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.6.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.7.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.7.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.7.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.7.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.7.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.7.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.7.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.40.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.40.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.40.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.40.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.40.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.40.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.40.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.40.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.41.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.41.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.41.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.41.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.41.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.41.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.41.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.41.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.41.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.41.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.42.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.42.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.42.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.42.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.42.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.42.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.42.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.42.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.42.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.42.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.43.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.43.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.43.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.43.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.43.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.43.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.43.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.44.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.44.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.44.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.44.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.44.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.44.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.44.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.44.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.45.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.45.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.45.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.45.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.45.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.45.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.45.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.45.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.45.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.45.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.46.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.46.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.46.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.46.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.46.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.46.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.46.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.46.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.46.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.46.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.47.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.47.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.47.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.47.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.47.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.47.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.47.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.48.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.48.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.48.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.48.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.48.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.48.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.48.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.48.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.49.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.49.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.49.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.49.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.49.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.49.mlp.down_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.49.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.49.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.49.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.49.mlp.up_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.50.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.50.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.50.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.50.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.50.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.50.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.50.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.50.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.50.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.50.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.51.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.51.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.51.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.51.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.51.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.51.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.51.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.52.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.52.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.52.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.52.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.52.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.52.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.52.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.52.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.53.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.53.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.53.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.53.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.53.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.53.mlp.gate_proj": {
      "bits": 2,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.53.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.53.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.54.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.54.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.54.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.54.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.54.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.54.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.54.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.54.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.55.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.55.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.55.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.55.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.55.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.55.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.55.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.56.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.56.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.56.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.56.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.56.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.56.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.56.mlp.up_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.57.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.57.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.57.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.57.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.57.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.57.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.57.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.57.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.58.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.58.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.58.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.58.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.58.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.58.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.58.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.58.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.59.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.59.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.59.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.59.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.59.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.59.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.59.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.60.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.60.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.60.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.60.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.60.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.60.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.60.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.61.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.61.linear_attn.out_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.61.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.61.mlp.down_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.61.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.61.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.61.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.61.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.62.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_a": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_b": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_qkv": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.62.linear_attn.in_proj_z": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.62.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.62.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.62.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.62.mlp.gate_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.62.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.62.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "language_model.model.layers.63.mlp.down_proj": {
      "bits": 3,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 0
      }
    },
    "model.language_model.layers.63.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.63.mlp.gate_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "language_model.model.layers.63.mlp.up_proj": {
      "bits": 4,
      "group_size": 256,
      "mode": "trellis",
      "trellis": {
        "L": 12,
        "code": "1mad",
        "axis": 1
      }
    },
    "model.language_model.layers.63.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.k_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.o_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.q_proj": {
      "bits": 4,
      "group_size": 64
    },
    "model.language_model.layers.63.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    },
    "language_model.model.layers.63.self_attn.v_proj": {
      "bits": 4,
      "group_size": 64
    }
  }
}"#
data_chars configChars config

/-- Verbatim `model.safetensors.index.json` of the model directory. -/
def index : String := r#"{
  "metadata": {
    "total_size": 11964671456,
    "total_parameters": 3383997168
  },
  "weight_map": {
    "lm_head.biases": "model-00001-of-00006.safetensors",
    "lm_head.scales": "model-00001-of-00006.safetensors",
    "lm_head.weight": "model-00001-of-00006.safetensors",
    "model.language_model.embed_tokens.biases": "model-00001-of-00006.safetensors",
    "model.language_model.embed_tokens.scales": "model-00001-of-00006.safetensors",
    "model.language_model.embed_tokens.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.input_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.A_log": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.conv1d.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.dt_bias": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_a.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_a.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_a.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_b.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_b.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_b.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_qkv.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_qkv.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_qkv.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_z.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_z.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.in_proj_z.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.norm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.out_proj.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.out_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.linear_attn.out_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.down_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.down_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.gate_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.gate_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.up_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.mlp.up_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.0.post_attention_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.input_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.A_log": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.conv1d.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.dt_bias": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_a.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_a.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_a.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_b.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_b.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_b.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_qkv.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_qkv.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_qkv.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_z.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_z.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.in_proj_z.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.norm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.out_proj.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.out_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.linear_attn.out_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.down_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.down_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.gate_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.gate_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.up_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.mlp.up_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.1.post_attention_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.10.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.10.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.k_norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.k_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.k_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.k_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.o_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.o_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.o_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.q_norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.q_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.q_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.q_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.v_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.v_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.11.self_attn.v_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.12.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.13.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.14.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.k_norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.k_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.k_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.k_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.o_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.o_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.o_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.q_norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.q_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.q_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.q_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.v_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.v_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.15.self_attn.v_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.16.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.16.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.16.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.17.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.18.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.k_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.k_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.k_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.k_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.o_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.o_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.o_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.q_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.q_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.q_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.q_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.v_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.v_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.19.self_attn.v_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.2.input_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.A_log": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.conv1d.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.dt_bias": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_a.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_a.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_a.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_b.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_b.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_b.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_qkv.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_qkv.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_qkv.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_z.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_z.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.in_proj_z.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.norm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.out_proj.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.out_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.linear_attn.out_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.down_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.down_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.gate_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.gate_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.up_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.mlp.up_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.2.post_attention_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.20.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.20.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.21.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.22.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.k_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.k_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.k_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.k_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.o_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.o_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.o_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.q_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.q_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.q_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.q_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.v_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.v_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.23.self_attn.v_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.24.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.25.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.26.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.k_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.k_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.k_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.k_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.o_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.o_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.o_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.q_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.q_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.q_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.q_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.v_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.v_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.27.self_attn.v_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.28.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.29.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.3.input_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.down_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.down_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.gate_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.gate_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.up_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.mlp.up_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.post_attention_layernorm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.k_norm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.k_proj.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.k_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.k_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.o_proj.biases": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.o_proj.scales": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.o_proj.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.q_norm.weight": "model-00001-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.q_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.q_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.q_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.v_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.v_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.3.self_attn.v_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.30.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.A_log": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.conv1d.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.dt_bias": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_a.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_a.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_a.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_b.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_b.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_b.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_qkv.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_qkv.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_qkv.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_z.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_z.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.in_proj_z.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.out_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.out_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.linear_attn.out_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.30.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.input_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.down_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.down_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.gate_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.gate_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.up_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.mlp.up_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.post_attention_layernorm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.k_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.k_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.k_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.k_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.o_proj.biases": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.o_proj.scales": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.o_proj.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.q_norm.weight": "model-00003-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.q_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.q_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.q_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.v_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.v_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.31.self_attn.v_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.32.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.33.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.34.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.k_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.k_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.k_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.k_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.o_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.o_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.o_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.q_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.q_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.q_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.q_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.v_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.v_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.35.self_attn.v_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.36.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.37.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.38.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.k_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.k_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.k_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.k_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.o_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.o_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.o_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.q_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.q_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.q_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.q_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.v_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.v_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.39.self_attn.v_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.4.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.40.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.41.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.42.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.42.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.k_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.k_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.k_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.k_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.o_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.o_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.o_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.q_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.q_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.q_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.q_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.v_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.v_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.43.self_attn.v_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.44.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.45.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.46.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.k_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.k_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.k_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.k_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.o_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.o_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.o_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.q_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.q_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.q_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.q_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.v_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.v_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.47.self_attn.v_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.48.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.49.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.5.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.5.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.50.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.50.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.k_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.k_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.k_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.k_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.o_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.o_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.o_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.q_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.q_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.q_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.q_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.v_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.v_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.51.self_attn.v_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.52.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.53.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.54.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.k_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.k_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.k_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.k_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.o_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.o_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.o_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.q_norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.q_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.q_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.q_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.v_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.v_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.55.self_attn.v_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.out_proj.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.out_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.linear_attn.out_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.down_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.down_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.gate_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.gate_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.up_proj.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.mlp.up_proj.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.56.post_attention_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.input_layernorm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.A_log": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.conv1d.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.dt_bias": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_a.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_a.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_a.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_b.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_b.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_b.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_qkv.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_qkv.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_qkv.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_z.biases": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_z.scales": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.in_proj_z.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.norm.weight": "model-00005-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.out_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.out_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.linear_attn.out_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.57.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.A_log": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.conv1d.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.dt_bias": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_a.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_a.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_a.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_b.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_b.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_b.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_qkv.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_qkv.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_qkv.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_z.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_z.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.in_proj_z.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.out_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.out_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.linear_attn.out_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.58.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.k_norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.k_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.k_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.k_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.o_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.o_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.o_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.q_norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.q_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.q_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.q_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.v_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.v_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.59.self_attn.v_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.6.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.A_log": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.conv1d.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.dt_bias": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_a.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_a.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_a.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_b.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_b.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_b.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_qkv.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_qkv.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_qkv.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_z.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_z.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.in_proj_z.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.out_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.out_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.linear_attn.out_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.6.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.60.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.A_log": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.conv1d.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.dt_bias": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_a.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_a.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_a.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_b.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_b.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_b.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_qkv.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_qkv.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_qkv.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_z.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_z.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.in_proj_z.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.out_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.out_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.linear_attn.out_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.60.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.A_log": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.conv1d.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.dt_bias": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_a.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_a.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_a.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_b.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_b.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_b.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_qkv.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_qkv.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_qkv.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_z.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_z.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.in_proj_z.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.out_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.out_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.linear_attn.out_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.61.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.A_log": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.conv1d.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.dt_bias": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_a.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_a.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_a.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_b.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_b.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_b.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_qkv.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_qkv.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_qkv.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_z.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_z.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.in_proj_z.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.out_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.out_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.linear_attn.out_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.62.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.input_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.down_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.down_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.gate_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.gate_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.up_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.mlp.up_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.post_attention_layernorm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.k_norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.k_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.k_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.k_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.o_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.o_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.o_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.q_norm.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.q_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.q_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.q_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.v_proj.biases": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.v_proj.scales": "model-00006-of-00006.safetensors",
    "model.language_model.layers.63.self_attn.v_proj.weight": "model-00006-of-00006.safetensors",
    "model.language_model.layers.7.input_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.down_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.down_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.gate_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.gate_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.up_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.mlp.up_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.post_attention_layernorm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.k_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.k_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.k_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.k_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.o_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.o_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.o_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.q_norm.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.q_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.q_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.q_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.v_proj.biases": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.v_proj.scales": "model-00004-of-00006.safetensors",
    "model.language_model.layers.7.self_attn.v_proj.weight": "model-00004-of-00006.safetensors",
    "model.language_model.layers.8.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.8.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.input_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.A_log": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.conv1d.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.dt_bias": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_a.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_a.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_a.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_b.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_b.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_b.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_qkv.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_qkv.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_qkv.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_z.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_z.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.in_proj_z.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.norm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.out_proj.biases": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.out_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.linear_attn.out_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.down_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.down_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.gate_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.gate_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.up_proj.scales": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.mlp.up_proj.weight": "model-00002-of-00006.safetensors",
    "model.language_model.layers.9.post_attention_layernorm.weight": "model-00002-of-00006.safetensors",
    "model.language_model.norm.weight": "model-00006-of-00006.safetensors",
    "model.visual.blocks.0.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.0.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.1.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.10.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.11.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.12.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.13.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.14.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.15.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.16.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.17.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.18.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.19.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.2.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.20.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.21.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.22.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.23.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.24.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.25.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.26.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.3.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.4.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.5.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.6.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.7.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.8.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.attn.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.attn.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.attn.qkv.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.attn.qkv.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.mlp.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.mlp.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.mlp.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.mlp.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.norm1.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.norm1.weight": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.norm2.bias": "model-00002-of-00006.safetensors",
    "model.visual.blocks.9.norm2.weight": "model-00002-of-00006.safetensors",
    "model.visual.merger.linear_fc1.bias": "model-00002-of-00006.safetensors",
    "model.visual.merger.linear_fc1.weight": "model-00002-of-00006.safetensors",
    "model.visual.merger.linear_fc2.bias": "model-00002-of-00006.safetensors",
    "model.visual.merger.linear_fc2.weight": "model-00002-of-00006.safetensors",
    "model.visual.merger.norm.bias": "model-00002-of-00006.safetensors",
    "model.visual.merger.norm.weight": "model-00002-of-00006.safetensors",
    "model.visual.patch_embed.proj.bias": "model-00002-of-00006.safetensors",
    "model.visual.patch_embed.proj.weight": "model-00002-of-00006.safetensors",
    "model.visual.pos_embed.weight": "model-00002-of-00006.safetensors",
    "mtp.fc.biases": "model-00001-of-00006.safetensors",
    "mtp.fc.scales": "model-00001-of-00006.safetensors",
    "mtp.fc.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.input_layernorm.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.down_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.down_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.down_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.gate_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.gate_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.gate_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.up_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.up_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.mlp.up_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.post_attention_layernorm.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.k_norm.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.k_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.k_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.k_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.o_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.o_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.o_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.q_norm.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.q_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.q_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.q_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.v_proj.biases": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.v_proj.scales": "model-00001-of-00006.safetensors",
    "mtp.layers.0.self_attn.v_proj.weight": "model-00001-of-00006.safetensors",
    "mtp.norm.weight": "model-00001-of-00006.safetensors",
    "mtp.pre_fc_norm_embedding.weight": "model-00001-of-00006.safetensors",
    "mtp.pre_fc_norm_hidden.weight": "model-00001-of-00006.safetensors"
  }
}"#
data_chars indexChars index

/-- Verbatim `turboquant_fold.json` of the model directory. -/
def fold : String := r#"{
  "source": "Qwen/Qwen3.8-27B@1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0",
  "generatedAt": "2026-09-17T22:40:32.009Z",
  "seed": 42,
  "r1": true,
  "r2": false,
  "hiddenSize": 5120,
  "gamma_convention": "stored+1 folded in; folded norms written as zeros",
  "final_gain": [
    1.9609375,
    1.75,
    1.9375,
    1.828125,
    1.671875,
    1.9375,
    1.9609375,
    1.8046875,
    1.859375,
    1.8125,
    1.90625,
    1.890625,
    1.8125,
    1.9375,
    1.828125,
    1.9375,
    1.9375,
    1.8515625,
    1.90625,
    1.765625,
    1.875,
    1.921875,
    1.78125,
    1.9609375,
    1.953125,
    1.9375,
    1.578125,
    2.390625,
    1.953125,
    1.796875,
    1.8828125,
    1.9609375,
    1.921875,
    1.9375,
    1.921875,
    1.890625,
    1.9375,
    1.8828125,
    1.890625,
    1.875,
    1.90625,
    1.875,
    1.875,
    1.9375,
    1.9453125,
    1.9375,
    1.9375,
    1.90625,
    1.9375,
    1.8125,
    1.8984375,
    1.875,
    1.890625,
    1.8828125,
    1.7421875,
    1.796875,
    2.0,
    2.0,
    1.9375,
    2.03125,
    1.9375,
    1.875,
    1.84375,
    1.953125,
    1.96875,
    1.96875,
    1.96875,
    1.796875,
    1.25,
    1.9921875,
    1.765625,
    1.953125,
    2.3125,
    1.84375,
    1.9609375,
    1.96875,
    1.8359375,
    1.875,
    1.9140625,
    1.953125,
    1.875,
    1.8515625,
    1.9375,
    1.828125,
    1.90625,
    1.9375,
    1.9375,
    2.25,
    1.9140625,
    1.90625,
    1.890625,
    1.7578125,
    1.921875,
    1.859375,
    1.890625,
    1.828125,
    1.875,
    1.90625,
    1.6875,
    1.84375,
    1.9375,
    2.015625,
    1.9609375,
    1.578125,
    1.921875,
    1.9375,
    1.875,
    1.828125,
    1.984375,
    1.9453125,
    1.875,
    1.9140625,
    1.875,
    1.7421875,
    1.796875,
    1.875,
    1.9765625,
    1.953125,
    1.984375,
    1.9140625,
    1.921875,
    1.796875,
    1.890625,
    1.78125,
    2.0,
    1.90625,
    1.921875,
    1.9375,
    1.796875,
    2.015625,
    1.9296875,
    1.96875,
    1.9375,
    1.921875,
    1.828125,
    1.921875,
    1.96875,
    1.9375,
    1.953125,
    1.640625,
    1.953125,
    1.9140625,
    1.8984375,
    1.8828125,
    1.9453125,
    1.90625,
    1.703125,
    1.890625,
    1.953125,
    1.0703125,
    2.0,
    1.953125,
    1.9375,
    1.921875,
    1.7734375,
    1.78125,
    1.8125,
    1.921875,
    1.59375,
    1.9921875,
    1.9921875,
    1.96875,
    2.0,
    1.9765625,
    1.9140625,
    1.921875,
    1.953125,
    1.9140625,
    1.9140625,
    1.9375,
    2.3125,
    1.984375,
    1.78125,
    1.90625,
    2.09375,
    1.640625,
    1.96875,
    1.96875,
    1.9609375,
    1.8125,
    1.765625,
    1.90625,
    1.9609375,
    1.9453125,
    1.5546875,
    1.9453125,
    1.953125,
    1.96875,
    1.859375,
    1.9609375,
    1.9609375,
    1.890625,
    1.9296875,
    1.796875,
    1.90625,
    1.9765625,
    1.96875,
    1.9375,
    1.90625,
    1.9296875,
    1.671875,
    1.8515625,
    1.859375,
    1.8984375,
    1.9296875,
    1.90625,
    1.96875,
    1.734375,
    1.828125,
    1.9609375,
    1.9375,
    1.828125,
    1.921875,
    1.984375,
    1.78125,
    1.9296875,
    1.828125,
    1.9375,
    2.0,
    1.78125,
    1.671875,
    1.90625,
    1.8046875,
    1.859375,
    1.96875,
    1.9296875,
    1.890625,
    1.875,
    1.875,
    1.921875,
    1.8828125,
    1.875,
    1.6796875,
    1.9609375,
    1.71875,
    1.46875,
    1.875,
    1.96875,
    1.78125,
    1.859375,
    1.953125,
    1.90625,
    1.9765625,
    1.96875,
    1.90625,
    1.8671875,
    1.96875,
    1.90625,
    1.90625,
    1.90625,
    1.890625,
    1.953125,
    1.921875,
    1.375,
    1.9453125,
    1.9609375,
    1.859375,
    1.6796875,
    1.9609375,
    1.875,
    1.625,
    1.796875,
    1.859375,
    1.90625,
    1.90625,
    1.9609375,
    1.84375,
    1.890625,
    1.828125,
    1.921875,
    1.9375,
    1.859375,
    1.9140625,
    1.921875,
    1.9140625,
    1.875,
    1.9375,
    1.890625,
    1.90625,
    1.796875,
    1.90625,
    1.8671875,
    1.75,
    1.71875,
    1.953125,
    1.875,
    1.7734375,
    1.953125,
    1.8671875,
    1.703125,
    1.9140625,
    1.984375,
    1.921875,
    1.921875,
    1.9375,
    1.8125,
    1.84375,
    1.953125,
    1.828125,
    1.765625,
    1.9296875,
    1.9453125,
    1.953125,
    1.9375,
    1.828125,
    1.828125,
    1.8046875,
    1.9375,
    1.90625,
    1.609375,
    1.0625,
    1.9453125,
    1.953125,
    1.8515625,
    1.65625,
    1.921875,
    1.90625,
    1.8125,
    1.890625,
    1.953125,
    1.8125,
    1.984375,
    1.7109375,
    1.734375,
    1.8046875,
    1.953125,
    1.9453125,
    1.7265625,
    1.9375,
    1.9140625,
    1.8125,
    1.5859375,
    1.8359375,
    1.71875,
    1.9296875,
    1.921875,
    1.890625,
    1.9140625,
    1.9140625,
    1.90625,
    1.8125,
    1.8125,
    1.9296875,
    1.96875,
    1.703125,
    2.015625,
    1.984375,
    1.9921875,
    1.859375,
    1.90625,
    1.921875,
    1.8515625,
    1.9375,
    1.78125,
    1.90625,
    1.765625,
    1.84375,
    1.890625,
    1.9375,
    1.84375,
    1.953125,
    1.9375,
    1.9453125,
    1.875,
    2.21875,
    1.9375,
    1.890625,
    1.90625,
    1.953125,
    1.96875,
    1.890625,
    1.859375,
    1.890625,
    1.90625,
    1.828125,
    1.8984375,
    1.8125,
    1.8515625,
    1.8671875,
    1.9375,
    1.84375,
    1.96875,
    1.859375,
    2.203125,
    1.859375,
    1.9140625,
    1.8125,
    1.9296875,
    1.828125,
    1.90625,
    1.9375,
    1.9140625,
    1.546875,
    1.875,
    1.875,
    1.875,
    1.875,
    1.90625,
    1.828125,
    1.96875,
    1.9453125,
    1.8984375,
    1.9453125,
    1.96875,
    1.921875,
    2.0,
    1.953125,
    1.9140625,
    1.765625,
    1.734375,
    1.8125,
    1.84375,
    1.828125,
    1.828125,
    1.75,
    1.828125,
    1.90625,
    2.015625,
    1.703125,
    1.90625,
    1.9296875,
    1.96875,
    1.828125,
    1.8984375,
    1.8125,
    1.90625,
    1.640625,
    1.921875,
    1.953125,
    1.8828125,
    1.8125,
    1.9140625,
    1.609375,
    1.8515625,
    1.3984375,
    1.9375,
    1.9375,
    1.859375,
    2.0,
    1.90625,
    1.703125,
    1.9453125,
    2.046875,
    1.953125,
    2.28125,
    1.734375,
    1.9453125,
    1.921875,
    1.953125,
    1.8828125,
    1.953125,
    1.7109375,
    1.96875,
    1.921875,
    1.8515625,
    1.59375,
    1.921875,
    1.90625,
    1.90625,
    1.90625,
    1.84375,
    1.9296875,
    1.890625,
    1.765625,
    1.875,
    2.0,
    2.0,
    1.9609375,
    1.921875,
    1.953125,
    1.90625,
    2.71875,
    1.921875,
    1.90625,
    2.15625,
    1.9765625,
    1.9375,
    1.921875,
    1.921875,
    1.90625,
    1.859375,
    1.875,
    1.875,
    1.578125,
    1.9609375,
    1.78125,
    1.921875,
    1.6875,
    1.96875,
    1.90625,
    1.953125,
    1.875,
    1.90625,
    1.9375,
    1.921875,
    1.8046875,
    1.8046875,
    1.875,
    1.859375,
    1.9140625,
    1.8125,
    1.875,
    1.984375,
    1.9375,
    1.875,
    1.59375,
    1.9140625,
    1.9375,
    1.921875,
    1.8359375,
    1.9453125,
    1.9921875,
    1.9375,
    1.859375,
    1.9296875,
    1.890625,
    1.71875,
    1.8359375,
    1.890625,
    1.859375,
    1.953125,
    1.84375,
    1.96875,
    1.90625,
    1.953125,
    1.796875,
    1.75,
    1.921875,
    1.921875,
    1.875,
    1.953125,
    1.90625,
    1.921875,
    1.9765625,
    1.9375,
    1.8828125,
    1.921875,
    1.953125,
    1.7890625,
    1.953125,
    1.8984375,
    1.9375,
    1.921875,
    1.84375,
    1.859375,
    1.9921875,
    1.90625,
    1.4609375,
    1.8125,
    1.953125,
    1.734375,
    1.96875,
    1.9609375,
    1.921875,
    1.75,
    1.859375,
    1.671875,
    1.890625,
    1.875,
    1.96875,
    1.921875,
    1.859375,
    1.8359375,
    2.03125,
    1.5546875,
    1.9296875,
    1.90625,
    1.796875,
    1.859375,
    1.859375,
    1.953125,
    1.703125,
    1.953125,
    1.84375,
    1.90625,
    1.875,
    1.9375,
    1.6640625,
    1.9453125,
    1.890625,
    1.84375,
    2.0,
    1.828125,
    1.9375,
    1.9140625,
    1.9453125,
    1.8125,
    1.9375,
    1.9453125,
    1.8359375,
    1.671875,
    1.9375,
    1.8828125,
    1.921875,
    1.9140625,
    1.828125,
    1.953125,
    1.96875,
    1.890625,
    1.25,
    1.921875,
    1.8359375,
    1.96875,
    1.9375,
    1.859375,
    1.8046875,
    1.953125,
    1.9375,
    1.9296875,
    1.984375,
    1.828125,
    1.8828125,
    1.9375,
    1.734375,
    1.7734375,
    1.953125,
    1.8359375,
    1.84375,
    1.734375,
    1.859375,
    1.96875,
    1.921875,
    1.953125,
    1.609375,
    1.796875,
    1.984375,
    1.8984375,
    1.765625,
    1.9453125,
    1.984375,
    1.9765625,
    1.8828125,
    1.828125,
    1.921875,
    1.9609375,
    1.8359375,
    1.9609375,
    1.8046875,
    1.90625,
    1.96875,
    1.9375,
    1.9375,
    1.9375,
    1.984375,
    1.953125,
    1.9296875,
    1.9296875,
    1.953125,
    1.921875,
    1.875,
    1.921875,
    1.9609375,
    1.921875,
    1.84375,
    1.9296875,
    1.90625,
    1.8671875,
    1.9375,
    1.9375,
    1.8671875,
    1.84375,
    1.96875,
    1.7734375,
    1.671875,
    1.921875,
    1.9375,
    1.9296875,
    1.9765625,
    1.90625,
    1.828125,
    1.953125,
    2.28125,
    1.890625,
    1.9296875,
    1.9140625,
    1.8984375,
    1.890625,
    1.9375,
    1.875,
    1.8203125,
    1.90625,
    1.875,
    1.96875,
    1.703125,
    1.953125,
    2.0625,
    1.953125,
    2.015625,
    1.921875,
    1.765625,
    1.875,
    1.921875,
    1.8671875,
    1.8125,
    1.8828125,
    1.953125,
    1.921875,
    1.78125,
    1.9609375,
    1.953125,
    2.0,
    1.8125,
    1.953125,
    1.8359375,
    1.90625,
    1.84375,
    1.921875,
    1.9140625,
    1.84375,
    1.71875,
    1.9140625,
    1.90625,
    1.890625,
    1.875,
    1.9453125,
    1.90625,
    1.8984375,
    1.90625,
    1.9375,
    1.8125,
    1.90625,
    1.8515625,
    1.703125,
    1.6875,
    1.9453125,
    1.9765625,
    1.71875,
    1.84375,
    1.484375,
    1.921875,
    1.921875,
    1.984375,
    2.0,
    1.875,
    1.8046875,
    1.921875,
    1.2578125,
    1.84375,
    1.8515625,
    1.921875,
    2.015625,
    1.96875,
    2.0,
    2.078125,
    1.9296875,
    1.8359375,
    2.0,
    1.9453125,
    1.84375,
    1.9296875,
    1.9375,
    2.4375,
    1.9296875,
    1.90625,
    1.890625,
    1.671875,
    1.859375,
    1.875,
    1.9375,
    1.921875,
    1.921875,
    1.7265625,
    1.8671875,
    1.71875,
    1.90625,
    1.921875,
    1.703125,
    1.9140625,
    1.953125,
    1.953125,
    1.875,
    1.9453125,
    1.9375,
    1.75,
    1.96875,
    1.90625,
    1.921875,
    1.8515625,
    1.828125,
    1.953125,
    1.8671875,
    1.9296875,
    1.859375,
    1.734375,
    1.859375,
    1.9140625,
    1.96875,
    1.609375,
    1.6875,
    1.9375,
    1.953125,
    1.90625,
    1.8359375,
    1.9375,
    1.9140625,
    2.625,
    1.984375,
    1.890625,
    1.78125,
    1.90625,
    1.96875,
    1.875,
    1.90625,
    1.828125,
    1.8984375,
    1.953125,
    1.890625,
    1.578125,
    1.84375,
    1.890625,
    1.953125,
    1.9765625,
    1.96875,
    1.90625,
    1.90625,
    1.96875,
    2.0,
    1.75,
    1.921875,
    1.8515625,
    1.875,
    1.765625,
    1.90625,
    1.953125,
    1.9375,
    1.828125,
    1.796875,
    1.8984375,
    1.875,
    1.9375,
    1.90625,
    1.96875,
    1.890625,
    1.984375,
    1.90625,
    2.0,
    1.859375,
    1.9140625,
    1.7265625,
    2.078125,
    1.859375,
    1.90625,
    1.9765625,
    1.734375,
    1.90625,
    1.9609375,
    1.921875,
    1.9375,
    1.828125,
    1.953125,
    1.9453125,
    1.875,
    1.953125,
    1.921875,
    1.890625,
    1.84375,
    1.875,
    1.765625,
    1.8125,
    1.875,
    1.96875,
    1.953125,
    1.96875,
    1.921875,
    1.71875,
    1.625,
    1.9375,
    1.8203125,
    1.71875,
    1.8515625,
    1.859375,
    1.921875,
    1.9375,
    1.84375,
    1.921875,
    1.953125,
    1.578125,
    1.859375,
    1.796875,
    1.875,
    1.9375,
    1.9375,
    1.96875,
    1.953125,
    1.9453125,
    1.84375,
    1.953125,
    1.9375,
    1.953125,
    1.828125,
    1.84375,
    1.96875,
    1.921875,
    1.9765625,
    1.984375,
    1.890625,
    1.828125,
    1.953125,
    1.921875,
    1.9140625,
    1.9375,
    1.859375,
    2.0,
    1.96875,
    1.9140625,
    1.828125,
    1.859375,
    1.8828125,
    1.78125,
    1.96875,
    1.921875,
    1.765625,
    1.78125,
    1.8359375,
    1.78125,
    1.921875,
    1.828125,
    1.953125,
    1.90625,
    1.9375,
    1.984375,
    1.8359375,
    1.96875,
    1.921875,
    1.78125,
    1.8984375,
    1.8984375,
    1.96875,
    1.90625,
    1.96875,
    1.9375,
    1.921875,
    1.828125,
    1.703125,
    1.859375,
    1.828125,
    1.921875,
    1.9921875,
    1.890625,
    1.90625,
    1.765625,
    1.890625,
    1.859375,
    1.8984375,
    1.8125,
    1.8515625,
    1.90625,
    1.71875,
    1.84375,
    1.921875,
    1.84375,
    1.859375,
    2.125,
    1.65625,
    1.625,
    1.859375,
    1.921875,
    1.75,
    1.9375,
    1.8828125,
    1.953125,
    1.9375,
    1.828125,
    1.8984375,
    1.9453125,
    1.96875,
    1.921875,
    1.8984375,
    1.890625,
    1.96875,
    1.984375,
    1.96875,
    1.921875,
    1.8125,
    1.953125,
    1.9375,
    1.9375,
    1.875,
    2.0,
    1.953125,
    1.890625,
    1.890625,
    1.828125,
    1.984375,
    1.953125,
    1.8828125,
    1.875,
    1.953125,
    1.890625,
    1.953125,
    1.84375,
    1.8359375,
    1.9453125,
    1.96875,
    1.890625,
    1.859375,
    1.8359375,
    2.0,
    1.953125,
    1.96875,
    1.921875,
    1.9453125,
    1.9375,
    1.90625,
    1.921875,
    1.921875,
    1.890625,
    1.9375,
    1.8125,
    2.1875,
    1.5625,
    1.859375,
    1.8984375,
    2.0625,
    1.9375,
    1.9296875,
    1.90625,
    1.9765625,
    1.6875,
    1.9140625,
    1.8984375,
    1.8203125,
    1.921875,
    1.8984375,
    1.53125,
    2.0625,
    1.9140625,
    1.8125,
    1.390625,
    1.9765625,
    1.953125,
    2.109375,
    2.03125,
    2.0625,
    2.015625,
    1.921875,
    1.65625,
    2.09375,
    1.890625,
    1.96875,
    2.046875,
    2.046875,
    2.234375,
    2.078125,
    2.0625,
    2.015625,
    2.09375,
    1.3046875,
    1.6484375,
    2.109375,
    2.046875,
    1.984375,
    1.9375,
    2.03125,
    2.0625,
    1.96875,
    2.0,
    2.03125,
    2.09375,
    1.96875,
    2.09375,
    2.046875,
    2.03125,
    2.0625,
    2.03125,
    2.09375,
    2.0,
    1.8125,
    2.03125,
    1.8125,
    2.09375,
    1.8359375,
    2.015625,
    1.8515625,
    2.0625,
    1.9765625,
    2.03125,
    2.03125,
    2.09375,
    2.0625,
    2.015625,
    2.09375,
    2.0625,
    2.03125,
    2.0625,
    2.03125,
    2.03125,
    2.03125,
    1.90625,
    1.625,
    2.03125,
    2.09375,
    2.1875,
    2.046875,
    2.09375,
    1.9453125,
    2.015625,
    1.640625,
    2.0,
    1.953125,
    2.09375,
    1.9921875,
    1.9609375,
    2.0625,
    2.03125,
    1.9921875,
    2.015625,
    2.09375,
    2.015625,
    2.03125,
    1.9609375,
    1.8984375,
    2.0,
    2.03125,
    1.96875,
    2.0,
    2.0,
    2.125,
    2.078125,
    2.0625,
    2.03125,
    2.109375,
    2.03125,
    2.03125,
    2.0625,
    2.125,
    2.078125,
    1.96875,
    2.0,
    2.03125,
    2.125,
    2.078125,
    2.0625,
    2.0625,
    2.0625,
    2.0625,
    2.015625,
    1.9609375,
    2.0625,
    2.0625,
    2.015625,
    2.03125,
    2.046875,
    2.0625,
    2.171875,
    2.0625,
    2.03125,
    2.0625,
    2.03125,
    1.84375,
    1.75,
    1.8828125,
    2.015625,
    2.0,
    2.0,
    2.09375,
    2.03125,
    2.125,
    2.03125,
    2.03125,
    2.109375,
    1.96875,
    1.5625,
    2.0625,
    1.9375,
    2.03125,
    2.046875,
    2.078125,
    2.0,
    2.03125,
    2.0625,
    2.046875,
    2.0625,
    2.046875,
    2.0,
    2.046875,
    2.0625,
    2.03125,
    1.9453125,
    2.0,
    2.0,
    2.0625,
    2.015625,
    1.859375,
    2.046875,
    2.0,
    1.984375,
    1.9453125,
    2.078125,
    2.125,
    1.9375,
    1.96875,
    1.96875,
    2.09375,
    2.09375,
    2.046875,
    1.75,
    2.0625,
    1.984375,
    1.9296875,
    1.90625,
    1.953125,
    2.0625,
    1.984375,
    2.0,
    1.625,
    2.125,
    2.015625,
    2.0,
    2.046875,
    2.0625,
    2.015625,
    2.046875,
    1.96875,
    2.03125,
    2.078125,
    2.046875,
    1.859375,
    1.7578125,
    2.015625,
    2.078125,
    2.0625,
    1.546875,
    2.0625,
    1.84375,
    2.046875,
    2.078125,
    2.09375,
    2.0625,
    2.140625,
    1.984375,
    2.03125,
    2.03125,
    1.875,
    1.9921875,
    2.015625,
    1.8359375,
    2.0,
    2.078125,
    1.9375,
    2.03125,
    1.90625,
    1.96875,
    2.09375,
    2.046875,
    1.7109375,
    1.9609375,
    2.0625,
    1.8984375,
    2.0625,
    2.03125,
    2.0625,
    2.0,
    2.015625,
    2.125,
    2.0625,
    2.03125,
    2.03125,
    2.03125,
    2.015625,
    2.03125,
    2.015625,
    1.96875,
    1.96875,
    2.015625,
    1.9609375,
    2.0,
    2.0625,
    2.109375,
    1.984375,
    1.9140625,
    2.0625,
    2.03125,
    1.8984375,
    1.5234375,
    1.9765625,
    2.0,
    1.65625,
    1.9375,
    2.09375,
    1.9921875,
    1.96875,
    2.03125,
    1.984375,
    1.4140625,
    2.015625,
    2.03125,
    1.9921875,
    2.0625,
    1.90625,
    2.09375,
    2.078125,
    2.0625,
    2.078125,
    2.046875,
    2.03125,
    1.96875,
    2.03125,
    2.03125,
    2.03125,
    2.09375,
    1.875,
    2.125,
    2.09375,
    1.953125,
    2.0625,
    2.0,
    2.078125,
    2.078125,
    2.015625,
    2.0,
    2.0,
    2.03125,
    2.015625,
    2.140625,
    2.09375,
    2.0,
    2.03125,
    2.0625,
    2.0625,
    1.546875,
    1.9453125,
    1.953125,
    1.8671875,
    2.0625,
    2.109375,
    2.015625,
    2.046875,
    2.078125,
    2.0,
    2.0,
    2.0625,
    1.4375,
    1.984375,
    1.65625,
    2.0,
    2.03125,
    1.9921875,
    1.1640625,
    2.046875,
    1.953125,
    1.9921875,
    1.9375,
    2.015625,
    2.015625,
    2.03125,
    2.03125,
    1.8046875,
    2.0,
    1.75,
    2.09375,
    1.640625,
    2.046875,
    1.953125,
    2.03125,
    2.109375,
    2.125,
    1.8125,
    1.8203125,
    2.0625,
    2.046875,
    2.0,
    2.046875,
    1.8671875,
    2.03125,
    1.984375,
    2.03125,
    2.09375,
    2.015625,
    1.9375,
    2.0625,
    1.90625,
    1.8984375,
    2.0625,
    2.0625,
    2.09375,
    2.0625,
    1.984375,
    2.0,
    2.078125,
    2.015625,
    2.0,
    1.953125,
    2.03125,
    2.09375,
    2.078125,
    2.0,
    2.125,
    2.03125,
    2.0625,
    2.0625,
    2.03125,
    2.03125,
    2.0625,
    2.03125,
    2.09375,
    2.0625,
    1.390625,
    1.9296875,
    1.46875,
    1.84375,
    2.09375,
    2.078125,
    1.75,
    2.03125,
    2.0,
    2.015625,
    1.984375,
    2.0625,
    1.84375,
    2.046875,
    2.0625,
    2.0625,
    1.984375,
    2.09375,
    2.0,
    2.09375,
    2.015625,
    1.640625,
    2.078125,
    1.9921875,
    2.0,
    2.078125,
    2.09375,
    2.03125,
    2.09375,
    2.046875,
    1.9453125,
    1.859375,
    2.0,
    2.078125,
    2.015625,
    2.0625,
    1.9765625,
    2.0,
    2.0625,
    2.09375,
    2.0625,
    2.015625,
    2.03125,
    1.84375,
    2.015625,
    1.890625,
    2.0,
    2.0625,
    1.9765625,
    1.984375,
    2.046875,
    2.03125,
    2.03125,
    2.0,
    1.7421875,
    1.953125,
    2.046875,
    2.0,
    2.0625,
    2.125,
    2.03125,
    2.0625,
    2.09375,
    1.953125,
    2.0,
    1.96875,
    2.046875,
    2.0625,
    2.0,
    1.90625,
    2.0625,
    2.03125,
    1.953125,
    2.03125,
    1.96875,
    2.0625,
    2.09375,
    2.046875,
    2.0625,
    2.0625,
    1.921875,
    2.0625,
    2.0625,
    2.03125,
    2.03125,
    2.078125,
    2.078125,
    2.03125,
    2.0,
    1.96875,
    2.0,
    1.828125,
    2.0625,
    2.0,
    2.03125,
    1.9609375,
    2.078125,
    1.984375,
    2.125,
    2.03125,
    2.09375,
    2.03125,
    1.8203125,
    2.0,
    1.4921875,
    1.9609375,
    1.609375,
    1.6171875,
    2.03125,
    1.890625,
    2.046875,
    2.03125,
    1.5,
    2.03125,
    1.984375,
    2.046875,
    1.8359375,
    1.9140625,
    2.03125,
    1.96875,
    2.03125,
    2.078125,
    2.0625,
    1.859375,
    2.09375,
    2.046875,
    1.96875,
    2.0,
    2.0,
    2.0625,
    2.0625,
    1.96875,
    1.703125,
    1.984375,
    1.578125,
    1.765625,
    1.859375,
    2.0625,
    1.9375,
    2.140625,
    2.0625,
    2.015625,
    2.0625,
    1.4765625,
    1.984375,
    1.7578125,
    2.03125,
    2.0,
    1.921875,
    1.4609375,
    2.046875,
    2.0,
    2.015625,
    2.09375,
    2.0625,
    2.0625,
    1.9921875,
    2.015625,
    2.046875,
    2.015625,
    2.03125,
    2.046875,
    2.03125,
    2.03125,
    2.125,
    1.9609375,
    2.0625,
    2.03125,
    2.015625,
    1.9765625,
    1.59375,
    2.03125,
    2.03125,
    2.09375,
    2.09375,
    2.0,
    1.65625,
    1.4765625,
    2.03125,
    2.09375,
    1.984375,
    2.09375,
    2.0,
    2.015625,
    2.03125,
    2.03125,
    2.046875,
    2.125,
    2.09375,
    1.953125,
    2.0625,
    1.8359375,
    1.953125,
    2.03125,
    2.0,
    2.0625,
    1.96875,
    2.03125,
    2.125,
    2.0625,
    2.0625,
    1.9765625,
    1.515625,
    2.046875,
    1.828125,
    1.78125,
    1.9765625,
    2.0625,
    1.84375,
    1.9921875,
    1.859375,
    1.984375,
    2.03125,
    2.0,
    2.0,
    2.078125,
    2.0625,
    2.03125,
    2.0,
    1.953125,
    1.46875,
    2.03125,
    1.828125,
    1.953125,
    2.046875,
    2.0,
    2.09375,
    2.03125,
    1.53125,
    2.0625,
    2.09375,
    2.0,
    2.0,
    1.8203125,
    1.828125,
    2.015625,
    2.0625,
    1.984375,
    1.6875,
    2.0625,
    1.9140625,
    2.03125,
    2.015625,
    2.0,
    1.9375,
    2.078125,
    2.078125,
    1.890625,
    2.0625,
    2.03125,
    1.859375,
    2.03125,
    2.03125,
    2.03125,
    2.0,
    2.0,
    2.078125,
    2.0,
    2.0,
    2.03125,
    2.0625,
    2.0625,
    1.96875,
    1.9296875,
    2.0,
    1.9609375,
    1.8359375,
    2.03125,
    2.046875,
    2.0,
    1.8671875,
    1.9296875,
    2.0625,
    2.140625,
    2.25,
    2.0625,
    2.03125,
    1.890625,
    1.9375,
    2.09375,
    2.03125,
    1.859375,
    2.109375,
    2.03125,
    2.0625,
    1.859375,
    2.0625,
    1.953125,
    1.953125,
    2.046875,
    2.0625,
    2.0625,
    2.125,
    2.078125,
    2.046875,
    1.96875,
    2.0625,
    2.0,
    1.8359375,
    2.078125,
    2.0625,
    2.046875,
    1.828125,
    2.0,
    2.0625,
    1.890625,
    2.0,
    2.03125,
    2.09375,
    2.03125,
    2.03125,
    1.53125,
    1.8125,
    1.84375,
    1.765625,
    2.03125,
    2.03125,
    2.046875,
    2.0625,
    1.8671875,
    2.0625,
    2.03125,
    2.015625,
    2.0625,
    1.71875,
    1.5625,
    2.0625,
    2.046875,
    2.015625,
    1.578125,
    2.25,
    2.09375,
    1.921875,
    2.078125,
    1.984375,
    2.0,
    2.078125,
    1.484375,
    2.046875,
    2.09375,
    2.0625,
    2.0,
    2.09375,
    2.0625,
    1.9453125,
    2.0,
    1.9375,
    2.03125,
    2.140625,
    2.078125,
    2.09375,
    2.046875,
    1.953125,
    2.0625,
    2.0625,
    2.0,
    1.9765625,
    2.03125,
    2.0625,
    2.0,
    1.96875,
    2.0625,
    1.953125,
    1.875,
    2.015625,
    1.796875,
    1.6875,
    2.03125,
    2.0625,
    2.03125,
    1.9375,
    2.046875,
    2.03125,
    2.0625,
    2.078125,
    2.03125,
    2.0,
    2.0,
    2.09375,
    2.0625,
    2.0625,
    1.625,
    2.03125,
    2.03125,
    2.0,
    2.03125,
    1.46875,
    2.046875,
    2.0,
    2.03125,
    2.0625,
    2.03125,
    1.9921875,
    2.046875,
    2.25,
    2.09375,
    1.984375,
    2.03125,
    1.75,
    2.0,
    2.015625,
    2.0625,
    2.0625,
    1.96875,
    2.0625,
    2.0625,
    1.9375,
    1.9375,
    1.78125,
    2.125,
    1.984375,
    1.96875,
    1.8828125,
    1.9453125,
    2.0625,
    2.0,
    2.09375,
    2.046875,
    1.953125,
    2.109375,
    2.09375,
    2.0625,
    1.7890625,
    2.015625,
    1.796875,
    2.0,
    1.953125,
    2.015625,
    2.03125,
    2.03125,
    1.96875,
    2.0625,
    2.09375,
    1.9375,
    2.09375,
    2.0625,
    2.0,
    2.0625,
    1.765625,
    1.875,
    1.53125,
    2.09375,
    2.0625,
    2.0625,
    2.0625,
    1.90625,
    2.0,
    1.6328125,
    1.921875,
    1.734375,
    2.03125,
    2.015625,
    1.984375,
    2.0625,
    1.9921875,
    2.03125,
    2.046875,
    2.03125,
    2.015625,
    2.03125,
    2.0625,
    0.984375,
    2.09375,
    2.03125,
    2.015625,
    2.046875,
    1.9375,
    2.046875,
    2.0625,
    1.9765625,
    2.21875,
    2.09375,
    2.09375,
    2.0,
    2.0625,
    1.90625,
    2.046875,
    2.03125,
    1.9609375,
    1.9375,
    2.0625,
    1.8359375,
    1.921875,
    2.0,
    2.0625,
    2.046875,
    2.046875,
    2.03125,
    2.0625,
    2.0625,
    1.96875,
    2.0625,
    2.109375,
    1.75,
    2.03125,
    2.046875,
    2.171875,
    2.046875,
    2.0,
    2.03125,
    2.0,
    2.03125,
    2.125,
    1.9921875,
    2.0625,
    2.0,
    1.59375,
    2.03125,
    1.984375,
    1.578125,
    1.984375,
    1.953125,
    1.625,
    2.03125,
    1.578125,
    2.125,
    2.046875,
    1.9921875,
    2.078125,
    1.9609375,
    2.0625,
    2.046875,
    1.984375,
    2.015625,
    2.015625,
    2.09375,
    2.09375,
    2.09375,
    2.03125,
    2.0625,
    2.03125,
    2.0,
    1.890625,
    2.0625,
    2.03125,
    1.984375,
    2.03125,
    1.96875,
    2.03125,
    2.015625,
    2.015625,
    2.015625,
    2.015625,
    1.984375,
    1.9453125,
    1.984375,
    2.0625,
    1.8828125,
    2.09375,
    1.890625,
    2.03125,
    2.03125,
    2.046875,
    2.046875,
    2.0625,
    2.03125,
    1.78125,
    2.03125,
    2.0,
    2.078125,
    2.03125,
    2.09375,
    2.078125,
    1.984375,
    1.921875,
    2.0,
    2.078125,
    2.03125,
    1.90625,
    2.046875,
    2.078125,
    1.953125,
    2.046875,
    2.0,
    1.71875,
    1.96875,
    2.109375,
    1.75,
    1.9609375,
    2.0,
    2.03125,
    2.03125,
    2.03125,
    2.015625,
    2.03125,
    1.8515625,
    2.03125,
    2.09375,
    1.875,
    2.375,
    2.0625,
    1.953125,
    2.03125,
    1.9453125,
    2.046875,
    2.046875,
    2.0,
    2.03125,
    1.875,
    2.0625,
    2.0,
    1.9921875,
    1.890625,
    2.03125,
    2.03125,
    2.03125,
    1.96875,
    2.09375,
    1.8984375,
    2.0,
    2.015625,
    1.9375,
    1.96875,
    2.0625,
    2.0625,
    2.03125,
    1.953125,
    2.078125,
    2.0625,
    2.0625,
    1.953125,
    1.984375,
    1.984375,
    2.09375,
    1.4765625,
    2.015625,
    2.0,
    2.046875,
    1.84375,
    1.96875,
    2.0625,
    1.6015625,
    2.046875,
    2.03125,
    2.125,
    1.8984375,
    1.5,
    2.0,
    2.03125,
    1.9921875,
    2.03125,
    2.03125,
    2.0625,
    1.953125,
    2.0625,
    2.0625,
    1.984375,
    1.9375,
    2.0625,
    1.953125,
    1.9375,
    1.984375,
    2.0,
    2.0,
    1.8515625,
    2.015625,
    2.03125,
    2.0,
    2.03125,
    2.09375,
    2.09375,
    2.046875,
    2.0,
    2.03125,
    2.0625,
    2.015625,
    2.0,
    2.03125,
    2.03125,
    1.984375,
    1.5390625,
    2.046875,
    2.0625,
    2.03125,
    1.71875,
    1.96875,
    1.9921875,
    2.03125,
    2.03125,
    2.0625,
    1.515625,
    2.0625,
    1.984375,
    2.0,
    1.734375,
    2.09375,
    1.5078125,
    2.0625,
    2.03125,
    1.71875,
    2.015625,
    2.0625,
    2.03125,
    2.125,
    2.03125,
    2.0625,
    2.03125,
    1.984375,
    2.046875,
    2.109375,
    2.03125,
    2.0625,
    2.0,
    2.0,
    2.109375,
    2.0625,
    1.9375,
    2.0,
    2.03125,
    2.078125,
    2.078125,
    2.046875,
    1.7578125,
    2.03125,
    2.0625,
    1.53125,
    2.03125,
    2.03125,
    2.0625,
    2.046875,
    2.03125,
    2.078125,
    2.03125,
    1.8984375,
    2.0625,
    2.0625,
    2.109375,
    2.0625,
    1.9609375,
    2.09375,
    2.0,
    1.984375,
    2.0625,
    2.046875,
    2.125,
    2.0,
    1.953125,
    2.0625,
    1.984375,
    2.0625,
    2.0,
    1.96875,
    2.015625,
    1.9609375,
    2.0625,
    1.828125,
    2.015625,
    1.9921875,
    2.09375,
    2.0625,
    1.8125,
    2.0625,
    2.0625,
    1.90625,
    1.9765625,
    2.03125,
    2.03125,
    0.9296875,
    2.0625,
    2.03125,
    1.984375,
    2.0,
    2.0625,
    2.078125,
    2.0625,
    1.84375,
    1.96875,
    2.0625,
    1.9375,
    1.96875,
    2.0625,
    1.984375,
    2.0,
    2.0625,
    1.6796875,
    1.96875,
    2.03125,
    1.8984375,
    1.96875,
    2.03125,
    2.0625,
    1.9921875,
    1.953125,
    1.984375,
    2.03125,
    1.90625,
    2.03125,
    2.0625,
    2.0625,
    2.03125,
    2.078125,
    2.0,
    1.96875,
    1.9609375,
    1.890625,
    2.03125,
    2.03125,
    2.0,
    1.984375,
    2.0,
    1.984375,
    2.046875,
    2.0625,
    2.015625,
    2.015625,
    1.921875,
    1.96875,
    1.921875,
    1.6875,
    2.125,
    1.609375,
    1.828125,
    2.046875,
    1.984375,
    2.0625,
    2.0625,
    2.015625,
    2.015625,
    2.234375,
    2.0625,
    1.953125,
    1.9375,
    2.015625,
    2.03125,
    2.1875,
    2.125,
    2.03125,
    2.03125,
    2.03125,
    2.046875,
    1.53125,
    2.0,
    1.5625,
    1.671875,
    1.90625,
    1.984375,
    1.9375,
    2.03125,
    1.9296875,
    2.046875,
    2.03125,
    2.109375,
    2.0625,
    2.09375,
    2.03125,
    1.859375,
    1.875,
    2.03125,
    2.03125,
    2.03125,
    2.078125,
    2.0,
    2.015625,
    1.96875,
    1.953125,
    2.09375,
    2.09375,
    2.09375,
    1.6953125,
    2.0625,
    2.0,
    2.0625,
    2.09375,
    2.0625,
    2.03125,
    1.84375,
    2.015625,
    1.609375,
    2.0625,
    2.0,
    1.96875,
    2.0,
    2.0625,
    1.640625,
    1.921875,
    1.984375,
    2.03125,
    1.8828125,
    1.9609375,
    2.03125,
    2.09375,
    1.953125,
    2.046875,
    1.8671875,
    2.0625,
    2.09375,
    1.859375,
    2.046875,
    1.765625,
    1.6875,
    1.96875,
    2.09375,
    1.9921875,
    2.0625,
    2.0625,
    2.0,
    1.921875,
    2.0,
    2.015625,
    1.921875,
    1.421875,
    2.03125,
    2.015625,
    2.0625,
    2.09375,
    2.0,
    2.0,
    1.953125,
    1.90625,
    2.09375,
    1.984375,
    2.0625,
    1.953125,
    1.984375,
    2.0,
    2.015625,
    2.0625,
    2.03125,
    1.921875,
    2.15625,
    2.03125,
    2.109375,
    2.03125,
    2.03125,
    1.96875,
    2.03125,
    1.4375,
    1.921875,
    2.0625,
    2.0625,
    2.0625,
    2.15625,
    2.078125,
    1.953125,
    1.921875,
    1.8125,
    2.078125,
    1.9765625,
    1.9609375,
    1.75,
    1.9375,
    1.984375,
    2.0,
    2.0625,
    1.890625,
    1.9609375,
    2.0,
    2.0,
    1.9140625,
    1.96875,
    1.921875,
    1.9921875,
    1.875,
    2.03125,
    1.7421875,
    2.0,
    2.03125,
    2.046875,
    2.15625,
    2.078125,
    1.9140625,
    2.0,
    2.09375,
    2.03125,
    1.984375,
    2.046875,
    2.09375,
    2.0,
    2.03125,
    1.9140625,
    2.0625,
    1.9921875,
    2.03125,
    2.03125,
    1.609375,
    2.0625,
    1.875,
    1.625,
    2.0,
    2.03125,
    1.6640625,
    1.859375,
    1.8359375,
    2.078125,
    2.03125,
    2.0,
    2.0,
    1.453125,
    2.0625,
    2.0625,
    1.9921875,
    2.0,
    2.0625,
    1.984375,
    2.046875,
    2.015625,
    1.8984375,
    2.03125,
    2.015625,
    2.0,
    2.03125,
    1.9921875,
    2.0625,
    2.03125,
    1.90625,
    2.09375,
    1.9765625,
    2.125,
    1.6875,
    2.046875,
    2.046875,
    2.09375,
    1.578125,
    1.96875,
    2.046875,
    1.875,
    2.046875,
    1.953125,
    2.078125,
    2.015625,
    2.0625,
    1.9375,
    2.046875,
    1.9453125,
    2.0625,
    2.03125,
    1.984375,
    2.03125,
    2.03125,
    2.09375,
    2.015625,
    2.0,
    2.0625,
    1.96875,
    2.125,
    2.046875,
    2.0,
    2.21875,
    2.0,
    2.0,
    2.078125,
    2.0625,
    2.03125,
    2.09375,
    2.171875,
    1.890625,
    2.0,
    2.03125,
    2.0,
    1.9765625,
    1.65625,
    2.0625,
    2.0625,
    1.984375,
    1.9765625,
    2.0625,
    2.03125,
    2.09375,
    2.0,
    2.0,
    2.03125,
    2.03125,
    1.984375,
    1.984375,
    1.9375,
    2.0,
    2.03125,
    2.09375,
    2.0625,
    2.0625,
    1.921875,
    2.0625,
    2.0625,
    2.0,
    2.03125,
    2.03125,
    2.03125,
    2.0625,
    2.09375,
    1.875,
    2.03125,
    2.09375,
    1.546875,
    2.03125,
    1.96875,
    2.140625,
    2.0,
    2.03125,
    2.09375,
    2.09375,
    2.09375,
    2.015625,
    2.046875,
    2.03125,
    2.046875,
    2.0625,
    2.0,
    1.96875,
    1.984375,
    1.890625,
    1.984375,
    2.03125,
    2.0,
    2.015625,
    1.8671875,
    2.0625,
    2.0625,
    1.625,
    1.6015625,
    1.96875,
    2.09375,
    2.09375,
    2.125,
    2.03125,
    2.0,
    2.03125,
    1.984375,
    1.5546875,
    2.015625,
    1.5390625,
    2.0625,
    2.0,
    1.59375,
    1.921875,
    1.984375,
    1.6328125,
    2.015625,
    2.03125,
    1.984375,
    2.0,
    1.9140625,
    1.96875,
    2.03125,
    2.015625,
    1.984375,
    2.03125,
    2.046875,
    1.890625,
    2.046875,
    2.015625,
    2.140625,
    2.0,
    2.125,
    2.0625,
    2.0625,
    1.765625,
    1.90625,
    1.9375,
    2.0625,
    1.9921875,
    2.078125,
    1.75,
    1.7578125,
    2.046875,
    2.03125,
    1.96875,
    1.9765625,
    1.9296875,
    1.90625,
    1.828125,
    2.03125,
    2.046875,
    2.078125,
    1.171875,
    2.03125,
    2.0,
    1.8515625,
    2.078125,
    2.0625,
    1.953125,
    1.96875,
    2.03125,
    2.078125,
    2.0625,
    2.0625,
    2.046875,
    2.09375,
    2.25,
    2.03125,
    2.03125,
    2.0625,
    2.015625,
    1.953125,
    2.0625,
    2.015625,
    2.046875,
    1.609375,
    1.984375,
    2.03125,
    2.0625,
    2.09375,
    1.96875,
    2.125,
    1.953125,
    1.984375,
    2.0,
    1.96875,
    1.65625,
    2.0,
    2.0625,
    1.84375,
    2.03125,
    2.0625,
    1.9375,
    2.015625,
    2.0625,
    1.59375,
    2.078125,
    1.984375,
    1.890625,
    2.0,
    2.0,
    1.375,
    1.3125,
    2.046875,
    2.03125,
    2.046875,
    1.9375,
    2.0625,
    2.046875,
    2.03125,
    1.984375,
    1.4921875,
    2.03125,
    1.84375,
    2.0,
    1.9453125,
    2.03125,
    2.0625,
    2.03125,
    2.09375,
    2.09375,
    2.046875,
    2.078125,
    2.03125,
    2.0625,
    2.0,
    1.734375,
    1.8828125,
    2.0625,
    2.03125,
    2.015625,
    2.046875,
    2.046875,
    2.0,
    2.0625,
    2.0625,
    1.890625,
    2.046875,
    2.03125,
    2.0,
    2.34375,
    2.0625,
    2.078125,
    2.0625,
    1.5625,
    2.09375,
    1.921875,
    2.03125,
    2.0625,
    1.9609375,
    2.015625,
    2.03125,
    1.53125,
    2.0625,
    2.03125,
    1.28125,
    2.0625,
    1.96875,
    2.03125,
    1.890625,
    1.9921875,
    2.03125,
    1.9609375,
    2.0,
    1.90625,
    2.0625,
    1.90625,
    2.125,
    1.9375,
    1.9921875,
    1.953125,
    2.0625,
    2.0625,
    2.0,
    2.03125,
    2.046875,
    1.875,
    2.0625,
    2.0625,
    1.9921875,
    2.078125,
    1.875,
    2.0625,
    1.9375,
    2.0625,
    1.8125,
    2.046875,
    2.125,
    2.046875,
    2.03125,
    2.09375,
    2.015625,
    2.0,
    2.109375,
    2.09375,
    1.9921875,
    2.015625,
    2.078125,
    2.0625,
    2.0625,
    1.9375,
    2.046875,
    1.8359375,
    1.953125,
    1.84375,
    1.9765625,
    2.03125,
    1.9375,
    2.0625,
    2.015625,
    2.0625,
    2.03125,
    1.9453125,
    1.9296875,
    1.90625,
    1.6875,
    2.0625,
    2.03125,
    2.078125,
    2.03125,
    1.640625,
    1.90625,
    1.71875,
    2.0625,
    1.9921875,
    2.015625,
    2.03125,
    1.9609375,
    2.03125,
    1.984375,
    1.984375,
    2.40625,
    2.0625,
    1.9921875,
    2.0,
    1.9296875,
    1.984375,
    1.9375,
    2.0,
    2.0,
    2.0625,
    1.90625,
    2.03125,
    2.328125,
    2.015625,
    2.03125,
    2.0625,
    2.0625,
    2.109375,
    2.015625,
    2.046875,
    2.015625,
    1.5625,
    2.15625,
    2.078125,
    2.03125,
    2.03125,
    2.0,
    1.703125,
    2.03125,
    1.9296875,
    2.0625,
    1.9453125,
    2.0,
    1.921875,
    2.09375,
    2.03125,
    2.078125,
    2.03125,
    2.015625,
    2.09375,
    2.03125,
    2.0,
    2.109375,
    1.75,
    2.03125,
    2.03125,
    2.015625,
    2.0625,
    2.078125,
    2.046875,
    1.921875,
    2.21875,
    2.03125,
    1.9453125,
    2.03125,
    2.0625,
    1.96875,
    2.078125,
    2.03125,
    2.109375,
    2.046875,
    2.0,
    2.03125,
    1.890625,
    1.765625,
    2.046875,
    1.3125,
    1.890625,
    2.0625,
    2.09375,
    1.875,
    2.03125,
    2.0625,
    2.078125,
    1.171875,
    2.0625,
    2.03125,
    2.09375,
    2.0625,
    2.03125,
    2.0625,
    2.09375,
    1.984375,
    2.0625,
    1.9375,
    2.09375,
    2.046875,
    2.0625,
    2.0625,
    2.03125,
    2.09375,
    2.0,
    2.03125,
    2.03125,
    1.9140625,
    1.6796875,
    2.0625,
    2.0625,
    2.015625,
    2.015625,
    2.046875,
    1.984375,
    1.640625,
    2.0625,
    2.015625,
    2.0625,
    2.0625,
    2.09375,
    1.9921875,
    2.046875,
    1.96875,
    1.8984375,
    2.078125,
    1.96875,
    2.09375,
    1.703125,
    2.015625,
    1.875,
    1.9453125,
    1.6328125,
    1.859375,
    2.03125,
    1.984375,
    1.171875,
    2.046875,
    2.09375,
    2.03125,
    2.0625,
    1.8125,
    1.9765625,
    2.125,
    1.3984375,
    1.890625,
    2.0,
    2.03125,
    2.0625,
    1.9375,
    2.03125,
    2.015625,
    1.859375,
    1.875,
    1.84375,
    2.046875,
    1.65625,
    2.0,
    2.03125,
    2.125,
    2.0625,
    2.125,
    2.046875,
    2.03125,
    2.0,
    2.03125,
    1.9375,
    2.0,
    2.03125,
    1.96875,
    2.09375,
    1.9921875,
    2.03125,
    2.046875,
    1.9609375,
    2.09375,
    1.9765625,
    2.0625,
    2.140625,
    1.796875,
    1.984375,
    2.0,
    1.765625,
    2.03125,
    2.09375,
    2.03125,
    2.0625,
    1.984375,
    2.0625,
    1.9453125,
    1.859375,
    2.0,
    2.078125,
    1.984375,
    2.03125,
    2.03125,
    1.9609375,
    2.078125,
    1.796875,
    2.015625,
    2.03125,
    1.9453125,
    2.0,
    2.03125,
    2.0,
    2.0625,
    2.0,
    2.0625,
    2.0,
    2.03125,
    2.015625,
    2.03125,
    1.984375,
    2.015625,
    2.0625,
    1.96875,
    2.0625,
    1.578125,
    1.703125,
    1.40625,
    2.03125,
    2.078125,
    1.921875,
    2.09375,
    2.03125,
    2.0625,
    2.15625,
    2.03125,
    2.03125,
    2.1875,
    1.859375,
    1.96875,
    2.0625,
    1.90625,
    1.96875,
    1.9140625,
    2.03125,
    1.9765625,
    2.0,
    2.03125,
    1.9453125,
    2.09375,
    2.03125,
    2.046875,
    2.078125,
    2.0625,
    2.078125,
    1.90625,
    1.75,
    1.9921875,
    1.96875,
    2.015625,
    2.078125,
    2.0625,
    2.03125,
    1.609375,
    2.03125,
    2.03125,
    2.03125,
    2.0625,
    1.6875,
    2.0,
    2.0625,
    1.984375,
    2.078125,
    1.890625,
    2.015625,
    2.03125,
    2.078125,
    2.09375,
    2.046875,
    1.984375,
    1.9140625,
    2.015625,
    2.0625,
    2.0625,
    2.09375,
    2.03125,
    2.046875,
    2.078125,
    2.0625,
    1.984375,
    2.0,
    2.078125,
    2.09375,
    1.546875,
    2.03125,
    2.09375,
    1.421875,
    2.046875,
    2.03125,
    1.96875,
    2.046875,
    2.0625,
    1.84375,
    1.625,
    2.015625,
    2.03125,
    2.046875,
    2.046875,
    2.03125,
    2.03125,
    2.0625,
    2.0625,
    2.0,
    2.03125,
    1.96875,
    1.9921875,
    1.3984375,
    2.0,
    2.0625,
    2.03125,
    2.09375,
    2.03125,
    1.9921875,
    2.0,
    2.0,
    2.09375,
    2.03125,
    2.09375,
    1.921875,
    2.0,
    1.625,
    2.09375,
    2.0625,
    1.9921875,
    2.0625,
    2.015625,
    2.0625,
    1.3125,
    2.09375,
    2.09375,
    1.75,
    2.03125,
    1.9453125,
    2.03125,
    2.03125,
    2.0625,
    1.9765625,
    2.078125,
    1.9375,
    2.03125,
    2.03125,
    2.046875,
    2.0625,
    1.765625,
    1.96875,
    2.0625,
    1.953125,
    2.09375,
    1.9375,
    2.09375,
    2.03125,
    1.96875,
    2.0625,
    2.03125,
    1.96875,
    1.9921875,
    1.875,
    1.96875,
    1.984375,
    1.890625,
    2.0,
    1.984375,
    1.78125,
    1.375,
    1.671875,
    1.953125,
    1.96875,
    2.125,
    2.0,
    1.734375,
    2.0625,
    2.03125,
    2.0625,
    2.0,
    1.9375,
    1.9765625,
    2.0625,
    2.0625,
    1.421875,
    2.046875,
    2.03125,
    1.9375,
    2.03125,
    2.046875,
    2.03125,
    2.0,
    2.03125,
    2.03125,
    2.03125,
    2.0,
    1.953125,
    2.09375,
    2.015625,
    1.9609375,
    2.046875,
    2.0,
    2.03125,
    2.09375,
    1.8984375,
    2.125,
    2.03125,
    2.078125,
    2.03125,
    2.046875,
    2.03125,
    2.0,
    2.0625,
    1.9921875,
    2.0625,
    1.96875,
    2.0,
    1.859375,
    1.71875,
    2.0625,
    2.0,
    2.03125,
    1.796875,
    2.0625,
    2.03125,
    2.0,
    1.828125,
    2.03125,
    2.03125,
    2.015625,
    1.921875,
    1.9140625,
    2.046875,
    1.921875,
    2.046875,
    2.03125,
    2.0625,
    1.671875,
    1.96875,
    1.734375,
    2.09375,
    2.1875,
    2.09375,
    1.6875,
    1.953125,
    2.0625,
    2.0625,
    2.03125,
    1.984375,
    2.0625,
    2.0625,
    1.5625,
    2.015625,
    1.9296875,
    2.078125,
    2.125,
    1.96875,
    2.0,
    2.03125,
    2.0,
    2.046875,
    2.0625,
    2.046875,
    2.03125,
    1.953125,
    2.0,
    2.046875,
    1.53125,
    1.96875,
    1.84375,
    2.03125,
    2.0625,
    2.03125,
    2.0,
    2.0,
    1.953125,
    2.046875,
    1.96875,
    1.796875,
    2.0625,
    1.875,
    1.875,
    1.984375,
    2.0,
    1.53125,
    2.046875,
    1.9375,
    2.09375,
    1.8671875,
    2.015625,
    2.28125,
    1.84375,
    1.9765625,
    2.0625,
    2.046875,
    2.0625,
    2.0625,
    1.796875,
    2.0,
    1.71875,
    1.96875,
    2.03125,
    1.890625,
    2.0,
    2.0625,
    2.0,
    1.96875,
    2.0625,
    1.9765625,
    2.03125,
    1.96875,
    2.015625,
    1.9375,
    1.90625,
    1.890625,
    1.921875,
    2.03125,
    2.03125,
    2.0625,
    2.0,
    2.046875,
    2.0625,
    2.015625,
    1.75,
    2.09375,
    2.078125,
    2.0,
    2.046875,
    1.96875,
    2.09375,
    2.046875,
    2.015625,
    2.09375,
    1.984375,
    1.640625,
    1.96875,
    2.140625,
    2.03125,
    2.03125,
    1.9921875,
    1.71875,
    2.09375,
    1.921875,
    2.0,
    2.09375,
    2.03125,
    2.03125,
    2.109375,
    2.0,
    2.140625,
    2.03125,
    2.0625,
    1.6171875,
    1.984375,
    1.9765625,
    2.03125,
    2.09375,
    1.421875,
    1.90625,
    1.296875,
    1.609375,
    1.984375,
    2.0,
    2.0,
    2.03125,
    1.9375,
    1.4296875,
    1.59375,
    1.890625,
    2.0625,
    1.9765625,
    2.015625,
    2.0,
    2.0625,
    1.984375,
    2.0,
    1.9765625,
    2.0625,
    2.0625,
    2.015625,
    2.078125,
    1.734375,
    1.703125,
    2.03125,
    2.0625,
    2.0625,
    2.0625,
    1.984375,
    2.078125,
    2.0625,
    2.03125,
    2.046875,
    2.0,
    2.0625,
    2.03125,
    1.9453125,
    2.03125,
    2.09375,
    1.9921875,
    1.4609375,
    2.03125,
    1.9921875,
    2.046875,
    2.09375,
    2.0,
    2.0,
    2.03125,
    2.09375,
    1.59375,
    1.921875,
    2.0,
    2.03125,
    2.015625,
    2.078125,
    2.0625,
    2.03125,
    1.9453125,
    1.875,
    2.0,
    2.0625,
    1.9609375,
    2.046875,
    1.9921875,
    2.0,
    2.03125,
    2.0625,
    1.8125,
    2.015625,
    1.921875,
    1.9609375,
    1.921875,
    1.7421875,
    1.71875,
    1.828125,
    1.78125,
    2.0625,
    2.015625,
    2.03125,
    1.984375,
    2.09375,
    2.03125,
    2.09375,
    1.9140625,
    2.03125,
    1.7578125,
    1.90625,
    1.703125,
    1.984375,
    2.0625,
    2.0625,
    2.015625,
    2.015625,
    2.0625,
    2.125,
    1.9453125,
    2.046875,
    2.078125,
    2.0625,
    2.015625,
    2.046875,
    1.8125,
    2.078125,
    2.09375,
    2.0625,
    2.03125,
    2.0,
    1.984375,
    1.921875,
    2.03125,
    2.09375,
    2.03125,
    2.046875,
    1.4375,
    2.03125,
    1.8984375,
    2.03125,
    1.9765625,
    1.96875,
    2.0,
    1.6640625,
    2.0625,
    2.0625,
    2.0,
    2.0625,
    2.0625,
    2.03125,
    2.046875,
    1.9765625,
    1.953125,
    2.03125,
    2.0625,
    2.0625,
    1.96875,
    2.03125,
    1.921875,
    2.0625,
    2.03125,
    2.09375,
    2.15625,
    2.03125,
    2.015625,
    2.03125,
    1.90625,
    1.75,
    2.03125,
    1.984375,
    2.0625,
    2.0625,
    2.0625,
    2.0625,
    2.046875,
    2.03125,
    2.078125,
    2.125,
    1.65625,
    1.96875,
    2.109375,
    2.03125,
    2.0625,
    1.984375,
    2.03125,
    1.46875,
    1.984375,
    1.953125,
    2.0,
    1.90625,
    2.03125,
    2.0625,
    1.9296875,
    2.0,
    1.9765625,
    2.078125,
    1.8984375,
    2.078125,
    1.78125,
    2.09375,
    1.9921875,
    2.0625,
    2.09375,
    2.0625,
    2.03125,
    1.9921875,
    2.09375,
    2.0625,
    2.0625,
    2.140625,
    1.828125,
    1.9765625,
    1.5703125,
    2.0625,
    2.0625,
    2.078125,
    2.078125,
    2.0625,
    2.03125,
    1.9765625,
    2.09375,
    1.515625,
    1.78125,
    2.03125,
    1.9375,
    2.046875,
    1.546875,
    1.65625,
    2.0625,
    1.9765625,
    2.03125,
    2.03125,
    1.984375,
    1.8984375,
    1.671875,
    1.9921875,
    1.9921875,
    1.96875,
    2.0,
    2.078125,
    2.03125,
    2.03125,
    2.0,
    1.96875,
    2.03125,
    2.0,
    2.03125,
    1.90625,
    1.8515625,
    1.7109375,
    2.0,
    2.078125,
    2.09375,
    2.03125,
    1.875,
    2.03125,
    1.9375,
    1.890625,
    2.03125,
    2.046875,
    2.03125,
    2.046875,
    1.890625,
    2.0,
    2.015625,
    2.046875,
    2.0625,
    2.0625,
    1.765625,
    1.71875,
    2.03125,
    2.109375,
    2.109375,
    1.7734375,
    2.03125,
    1.96875,
    2.09375,
    2.0625,
    2.125,
    1.984375,
    2.03125,
    1.90625,
    2.03125,
    2.0625,
    2.0625,
    2.0,
    2.0625,
    2.09375,
    1.953125,
    1.953125,
    1.984375,
    2.03125,
    1.9765625,
    1.984375,
    1.671875,
    2.015625,
    2.0,
    1.890625,
    2.109375,
    2.0,
    1.796875,
    2.03125,
    2.046875,
    2.0625,
    1.5703125,
    2.0625,
    2.09375,
    2.03125,
    1.875,
    1.9921875,
    2.03125,
    2.09375,
    1.953125,
    2.09375,
    1.84375,
    1.9375,
    2.046875,
    1.9375,
    1.9921875,
    2.03125,
    2.078125,
    1.515625,
    2.09375,
    1.953125,
    2.0,
    2.03125,
    1.984375,
    1.9375,
    1.25,
    2.0625,
    2.109375,
    2.03125,
    1.9609375,
    1.96875,
    2.0625,
    2.125,
    1.5,
    2.0,
    1.984375,
    1.9375,
    1.796875,
    2.078125,
    2.03125,
    2.0625,
    2.125,
    2.0625,
    2.015625,
    2.03125,
    2.125,
    2.046875,
    2.0625,
    1.984375,
    1.890625,
    1.796875,
    2.09375,
    2.0625,
    2.03125,
    2.0,
    2.0625,
    1.9921875,
    1.921875,
    2.09375,
    2.0625,
    1.96875,
    1.859375,
    2.03125,
    2.09375,
    1.984375,
    2.03125,
    1.9765625,
    1.4140625,
    1.96875,
    1.9609375,
    1.796875,
    2.0,
    2.046875,
    2.0625,
    1.71875,
    2.078125,
    1.890625,
    2.09375,
    1.8984375,
    1.9375,
    2.03125,
    2.0625,
    2.125,
    1.875,
    2.03125,
    1.9609375,
    2.09375,
    2.046875,
    1.84375,
    2.0625,
    2.03125,
    2.03125,
    2.03125,
    1.984375,
    1.984375,
    2.03125,
    2.0625,
    2.109375,
    2.03125,
    2.03125,
    2.03125,
    1.953125,
    2.09375,
    1.953125,
    2.015625,
    2.03125,
    2.046875,
    2.03125,
    2.0625,
    2.09375,
    1.984375,
    2.0625,
    2.09375,
    1.96875,
    2.0625,
    1.9609375,
    2.03125,
    1.921875,
    1.9296875,
    1.734375,
    2.0625,
    2.0,
    2.109375,
    1.234375,
    1.890625,
    2.0,
    2.03125,
    2.03125,
    2.046875,
    2.0,
    1.921875,
    1.953125,
    2.0625,
    1.84375,
    2.0,
    2.0,
    2.0625,
    1.9375,
    2.046875,
    2.015625,
    2.03125,
    1.984375,
    2.03125,
    1.875,
    2.03125,
    1.984375,
    2.109375,
    1.953125,
    2.09375,
    2.0625,
    1.7578125,
    2.09375,
    2.09375,
    1.765625,
    2.0,
    1.96875,
    1.984375,
    2.0625,
    2.09375,
    2.25,
    2.03125,
    2.0625,
    1.921875,
    2.0,
    1.859375,
    2.0625,
    2.03125,
    1.90625,
    2.015625,
    1.9609375,
    1.953125,
    2.0625,
    2.0625,
    1.984375,
    2.0625,
    2.015625,
    2.015625,
    2.0625,
    2.0,
    2.0625,
    2.046875,
    2.03125,
    1.765625,
    2.0,
    2.015625,
    1.84375,
    2.078125,
    2.0,
    2.03125,
    2.0625,
    2.046875,
    2.078125,
    1.9140625,
    2.0625,
    2.015625,
    2.09375,
    2.046875,
    1.78125,
    2.0625,
    2.046875,
    1.9921875,
    1.9609375,
    2.0,
    1.9609375,
    2.0,
    2.0,
    1.96875,
    2.015625,
    1.1484375,
    2.0625,
    2.0625,
    2.0625,
    1.90625,
    1.71875,
    1.9453125,
    1.765625,
    2.015625,
    2.0,
    1.9921875,
    2.03125,
    2.0,
    2.015625,
    2.0625,
    2.0,
    2.0625,
    2.03125,
    1.9921875,
    1.9609375,
    1.9140625,
    2.03125,
    2.046875,
    2.03125,
    1.5859375,
    1.8984375,
    2.0,
    1.8671875,
    2.0625,
    2.03125,
    2.09375,
    2.125,
    2.03125,
    2.09375,
    1.6875,
    2.09375,
    2.15625,
    2.0625,
    2.0,
    1.75,
    2.03125,
    2.015625,
    2.03125,
    2.0625,
    2.03125,
    2.03125,
    2.0625,
    1.796875,
    2.0,
    2.078125,
    1.921875,
    2.0625,
    2.0,
    2.0,
    1.7109375,
    2.015625,
    2.0625,
    1.9375,
    1.984375,
    2.03125,
    2.03125,
    2.0625,
    1.5625,
    2.09375,
    1.734375,
    2.03125,
    2.046875,
    1.96875,
    2.078125,
    2.0,
    2.0,
    2.03125,
    2.0,
    1.6875,
    2.03125,
    1.9453125,
    1.953125,
    2.03125,
    2.0625,
    2.0625,
    2.015625,
    2.03125,
    2.09375,
    1.984375,
    1.4296875,
    2.09375,
    1.8359375,
    1.6875,
    2.078125,
    1.625,
    1.953125,
    2.0625,
    2.03125,
    1.9921875,
    2.03125,
    1.8515625,
    2.0625,
    2.03125,
    1.96875,
    1.90625,
    2.03125,
    2.03125,
    2.0625,
    2.09375,
    2.0625,
    2.046875,
    1.9375,
    2.0,
    2.046875,
    2.03125,
    2.0,
    2.03125,
    2.03125,
    2.046875,
    1.8125,
    2.046875,
    2.03125,
    2.03125,
    1.9453125,
    1.796875,
    1.359375,
    1.984375,
    1.59375,
    1.984375,
    2.0,
    2.0625,
    1.984375,
    1.8671875,
    2.03125,
    2.0625,
    1.9609375,
    2.171875,
    2.125,
    2.0,
    2.0,
    1.90625,
    2.09375,
    1.59375,
    2.03125,
    1.6171875,
    1.9375,
    2.03125,
    2.078125,
    2.015625,
    2.0625,
    2.03125,
    2.0625,
    2.0625,
    2.0,
    2.03125,
    2.03125,
    1.96875,
    1.890625,
    2.0625,
    2.03125,
    1.953125,
    2.03125,
    1.8046875,
    2.078125,
    2.140625,
    1.984375,
    1.6953125,
    2.0625,
    2.0,
    2.09375,
    2.03125,
    1.9375,
    1.5,
    2.03125,
    2.0625,
    2.015625,
    1.9375,
    2.03125,
    2.0625,
    1.96875,
    2.046875,
    2.046875,
    2.03125,
    1.953125,
    2.09375,
    1.9453125,
    2.015625,
    1.625,
    1.96875,
    1.625,
    1.9921875,
    2.015625,
    2.03125,
    2.0625,
    2.0625,
    1.8984375,
    2.03125,
    2.0625,
    2.0625,
    2.046875,
    2.0,
    2.0625,
    2.03125,
    2.0625,
    1.859375,
    2.03125,
    2.0625,
    1.9296875,
    2.0625,
    2.0625,
    2.0625,
    1.828125,
    1.8359375,
    2.0625,
    2.125,
    1.9453125,
    2.015625,
    2.03125,
    2.109375,
    2.046875,
    1.796875,
    2.0,
    1.0390625,
    1.90625,
    2.109375,
    2.0,
    2.0625,
    1.7734375,
    2.03125,
    2.03125,
    0.71484375,
    2.03125,
    2.09375,
    2.015625,
    2.09375,
    2.03125,
    2.015625,
    2.09375,
    2.03125,
    2.046875,
    2.03125,
    1.9765625,
    2.046875,
    2.0,
    1.890625,
    2.15625,
    1.8203125,
    2.03125,
    1.921875,
    1.9296875,
    2.03125,
    1.9765625,
    2.0,
    1.9765625,
    2.03125,
    2.0,
    1.984375,
    2.0625,
    2.03125,
    1.953125,
    2.0625,
    2.0,
    1.9140625,
    2.03125,
    2.046875,
    2.078125,
    1.984375,
    1.8515625,
    2.015625,
    2.0625,
    2.046875,
    2.046875,
    1.984375,
    2.046875,
    2.0625,
    2.015625,
    1.984375,
    2.03125,
    1.453125,
    1.546875,
    2.0625,
    1.984375,
    2.046875,
    1.96875,
    2.0625,
    1.8828125,
    2.015625,
    2.03125,
    2.09375,
    2.0,
    1.890625,
    2.03125,
    2.03125,
    1.890625,
    2.078125,
    2.0625,
    2.078125,
    2.078125,
    2.03125,
    1.984375,
    2.046875,
    2.125,
    2.03125,
    1.90625,
    2.125,
    2.0625,
    2.03125,
    2.0,
    2.03125,
    2.0625,
    2.03125,
    2.0625,
    2.015625,
    2.046875,
    1.5078125,
    2.0625,
    1.625,
    2.0,
    2.0625,
    2.0,
    2.015625,
    2.0625,
    2.03125,
    2.09375,
    1.890625,
    1.953125,
    2.015625,
    2.03125,
    1.875,
    2.0625,
    1.9765625,
    2.03125,
    2.0,
    1.796875,
    1.890625,
    1.765625,
    1.828125,
    1.8984375,
    1.9921875,
    1.796875,
    1.8515625,
    1.953125,
    1.875,
    1.9296875,
    1.828125,
    1.953125,
    1.671875,
    1.796875,
    1.875,
    1.90625,
    1.640625,
    1.5078125,
    1.9140625,
    2.0,
    1.6875,
    1.921875,
    1.90625,
    1.8828125,
    1.453125,
    1.7578125,
    1.921875,
    1.9375,
    1.953125,
    1.828125,
    1.8984375,
    1.9375,
    1.84375,
    1.8359375,
    1.8671875,
    1.890625,
    1.8125,
    1.921875,
    1.8125,
    1.8125,
    1.90625,
    1.921875,
    2.0,
    1.78125,
    1.859375,
    1.875,
    1.953125,
    1.953125,
    1.890625,
    1.90625,
    1.96875,
    1.9765625,
    1.8359375,
    1.703125,
    2.28125,
    1.953125,
    1.7578125,
    2.0625,
    1.859375,
    1.859375,
    1.875,
    1.890625,
    1.921875,
    1.984375,
    1.8359375,
    1.8828125,
    1.6640625,
    1.734375,
    1.7890625,
    1.875,
    1.9765625,
    1.9140625,
    1.9375,
    1.890625,
    1.90625,
    1.9140625,
    1.890625,
    1.9375,
    1.8984375,
    1.671875,
    1.9453125,
    1.84375,
    1.984375,
    1.921875,
    1.84375,
    2.078125,
    1.984375,
    1.96875,
    1.953125,
    1.734375,
    1.9453125,
    1.953125,
    1.859375,
    1.9453125,
    1.90625,
    1.875,
    2.03125,
    1.828125,
    1.9296875,
    1.984375,
    1.9765625,
    1.71875,
    1.921875,
    1.9375,
    1.921875,
    1.953125,
    1.90625,
    1.953125,
    1.90625,
    1.90625,
    1.921875,
    1.796875,
    1.890625,
    1.9296875,
    1.921875,
    1.90625,
    1.84375,
    1.953125,
    1.9375,
    1.96875,
    1.921875,
    1.875,
    1.96875,
    1.890625,
    1.9609375,
    1.9609375,
    1.953125,
    1.90625,
    1.953125,
    1.921875,
    1.84375,
    1.953125,
    1.984375,
    1.8828125,
    1.9375,
    1.921875,
    1.90625,
    1.796875,
    1.953125,
    1.890625,
    1.90625,
    1.9375,
    1.7421875,
    1.8984375,
    1.703125,
    1.9296875,
    1.921875,
    1.6015625,
    1.671875,
    1.9140625,
    1.9375,
    1.9140625,
    1.9375,
    1.640625,
    1.8125,
    1.9453125,
    1.890625,
    1.8671875,
    2.046875,
    1.8515625,
    1.921875,
    1.953125,
    1.9296875,
    1.96875,
    1.9296875,
    1.765625,
    1.59375,
    1.84375,
    1.796875,
    1.9453125,
    1.9296875,
    1.8125,
    1.890625,
    1.71875,
    1.890625,
    1.890625,
    1.84375,
    1.921875,
    1.9375,
    1.875,
    1.6953125,
    1.859375,
    1.765625,
    1.953125,
    1.921875,
    1.9140625,
    1.90625,
    1.5625,
    1.890625,
    1.921875,
    1.90625,
    1.5625,
    1.671875,
    1.765625,
    1.9453125,
    1.84375,
    1.75,
    1.9296875,
    1.6640625,
    1.8125,
    1.875,
    1.953125,
    1.890625,
    1.921875,
    2.6875,
    1.4921875,
    1.90625,
    1.890625,
    1.9609375,
    1.859375,
    1.921875,
    1.875,
    1.828125,
    1.9140625,
    1.890625,
    1.90625,
    1.90625,
    2.03125,
    1.140625,
    1.8671875,
    1.9453125,
    1.7734375,
    1.984375,
    1.8671875,
    1.9375,
    1.9375,
    1.890625,
    2.0625,
    1.96875,
    1.8671875,
    1.7734375,
    1.953125,
    1.828125,
    1.625,
    1.859375,
    1.828125,
    1.828125,
    1.8984375,
    1.796875,
    1.96875,
    1.7265625,
    1.765625,
    1.71875,
    1.9296875,
    1.796875,
    1.9609375,
    1.8125,
    1.875,
    1.734375,
    1.9296875,
    1.875,
    1.25,
    1.8828125,
    1.9140625,
    1.859375,
    1.65625,
    2.015625,
    1.90625,
    1.515625,
    1.890625,
    1.90625,
    1.9375,
    1.953125,
    1.953125,
    1.953125,
    1.96875,
    1.890625,
    1.859375,
    1.9140625,
    1.875,
    1.859375,
    1.953125,
    1.828125,
    1.859375,
    1.875,
    1.9296875,
    1.890625,
    1.875,
    1.765625,
    1.8515625,
    1.7734375,
    1.734375,
    1.890625,
    1.953125,
    1.3671875,
    1.828125,
    1.921875,
    1.6953125,
    1.8828125,
    1.90625,
    1.890625,
    1.8828125,
    1.84375,
    1.9921875,
    1.75,
    1.875,
    1.875,
    1.9375,
    1.8671875,
    1.890625,
    1.96875,
    1.859375,
    1.9375,
    1.8359375,
    1.953125,
    1.953125,
    1.875,
    1.734375,
    1.484375,
    1.90625,
    1.8984375,
    1.703125,
    1.6953125,
    1.921875,
    1.953125,
    1.859375,
    1.921875,
    1.953125,
    1.875,
    1.953125,
    1.890625,
    1.796875,
    1.9609375,
    1.96875,
    1.90625,
    1.859375,
    1.890625,
    1.890625,
    2.09375,
    1.6640625,
    1.9609375,
    1.640625,
    1.890625,
    1.9375,
    1.875,
    1.9375,
    1.953125,
    1.890625,
    1.671875,
    1.9375,
    1.9375,
    1.9296875,
    1.796875,
    1.875,
    1.9765625,
    1.890625,
    1.875,
    1.9375,
    1.953125,
    2.15625,
    1.9375,
    1.78125,
    1.984375,
    1.734375,
    1.921875,
    2.03125,
    1.96875,
    1.84375,
    1.890625,
    1.8671875,
    1.859375,
    1.8828125,
    2.03125,
    1.96875,
    1.8515625,
    1.734375,
    1.9375,
    1.890625,
    1.78125,
    1.765625,
    1.90625,
    1.9765625,
    1.953125,
    2.0,
    2.0625,
    1.921875,
    1.890625,
    1.78125,
    1.90625,
    1.875,
    1.90625,
    2.5,
    1.9296875,
    1.875,
    1.8203125,
    1.90625,
    1.8828125,
    1.8828125,
    1.9140625,
    1.9765625,
    1.90625,
    1.90625,
    1.890625,
    1.578125,
    1.84375,
    1.890625,
    1.890625,
    1.890625,
    1.9453125,
    1.921875,
    1.953125,
    1.9296875,
    1.8984375,
    1.9921875,
    1.890625,
    1.8828125,
    1.8984375,
    2.40625,
    1.890625,
    1.9296875,
    1.890625,
    1.78125,
    1.8984375,
    1.6796875,
    1.9140625,
    1.9140625,
    1.96875,
    1.953125,
    1.9375,
    1.9140625,
    1.921875,
    1.828125,
    1.84375,
    1.9375,
    1.765625,
    1.9453125,
    1.828125,
    1.90625,
    1.7890625,
    1.859375,
    1.578125,
    1.609375,
    2.1875,
    1.921875,
    1.796875,
    1.96875,
    1.5,
    1.953125,
    1.828125,
    1.9375,
    2.125,
    1.953125,
    1.953125,
    1.6484375,
    1.921875,
    2.0,
    1.859375,
    1.6484375,
    2.0,
    1.9765625,
    1.96875,
    1.890625,
    1.921875,
    1.9296875,
    1.875,
    1.890625,
    1.9140625,
    1.9140625,
    1.84375,
    1.9375,
    1.9140625,
    1.84375,
    1.890625,
    1.9765625,
    1.8984375,
    1.921875,
    1.9375,
    1.8515625,
    1.921875,
    2.1875,
    1.84375,
    1.9296875,
    1.5,
    1.984375,
    1.953125,
    1.9375,
    1.9375,
    1.859375,
    1.78125,
    1.9609375,
    1.9140625,
    1.8046875,
    1.828125,
    1.890625,
    1.8203125,
    1.6875,
    1.90625,
    1.8828125,
    1.890625,
    1.859375,
    1.796875,
    1.828125,
    1.9375,
    1.890625,
    1.890625,
    1.921875,
    1.8359375,
    1.8828125,
    1.734375,
    1.8046875,
    1.9375,
    1.890625,
    1.890625,
    2.03125,
    1.890625,
    1.9453125,
    1.890625,
    1.921875,
    1.859375,
    1.921875,
    2.0,
    1.8828125,
    1.9296875,
    1.78125,
    1.953125,
    1.921875,
    1.953125,
    1.75,
    1.9296875,
    1.921875,
    1.953125,
    1.9140625,
    2.0,
    1.921875,
    2.0,
    1.9375,
    1.921875,
    1.96875,
    1.9140625,
    1.9453125,
    1.921875,
    1.953125,
    1.953125,
    1.8984375,
    1.9453125,
    1.859375,
    1.859375,
    1.90625,
    1.953125,
    1.96875,
    1.9140625,
    1.9296875,
    1.953125,
    1.953125,
    1.8125,
    1.609375,
    1.921875,
    1.921875,
    1.796875,
    1.921875,
    1.953125,
    1.984375,
    1.875,
    1.9765625,
    1.828125,
    1.90625,
    1.7578125,
    1.953125,
    1.8203125,
    1.921875,
    1.921875,
    1.84375,
    1.984375,
    1.921875,
    2.0,
    1.828125,
    1.90625,
    1.8203125,
    1.8125,
    1.8359375,
    1.8046875,
    1.953125,
    1.84375,
    1.921875,
    1.84375,
    1.890625,
    1.9765625,
    1.9375,
    1.921875,
    1.96875,
    2.046875,
    1.96875,
    1.96875,
    1.90625,
    1.984375,
    1.984375,
    1.828125,
    1.9296875,
    1.6953125,
    1.84375,
    1.921875,
    1.875,
    1.890625,
    1.875,
    1.78125,
    2.0625,
    1.8203125,
    1.8125,
    1.921875,
    1.890625,
    1.9375,
    1.984375,
    1.9453125,
    1.78125,
    1.9453125,
    1.90625,
    1.984375,
    1.859375,
    1.859375,
    1.8515625,
    1.8671875,
    1.9375,
    1.875,
    1.890625,
    1.90625,
    1.921875,
    1.7421875,
    1.9140625,
    1.984375,
    1.96875,
    1.84375,
    1.8046875,
    1.9140625,
    1.921875,
    1.9140625,
    1.890625,
    1.921875,
    1.9296875,
    1.9375,
    1.984375,
    1.90625,
    1.984375,
    1.9375,
    1.71875,
    1.875,
    1.765625,
    1.890625,
    1.8515625,
    1.9375,
    1.8125,
    1.84375,
    1.8125,
    1.90625,
    1.921875,
    1.953125,
    1.96875,
    1.796875,
    1.96875,
    1.90625,
    1.890625,
    1.921875,
    1.890625,
    1.9609375,
    1.828125,
    1.90625,
    1.9375,
    1.9453125,
    1.921875,
    1.8203125,
    1.890625,
    1.90625,
    1.9375,
    1.9453125,
    1.875,
    1.8515625,
    1.921875,
    1.78125,
    1.90625,
    2.03125,
    1.65625,
    1.890625,
    1.828125,
    1.890625,
    1.96875,
    1.546875,
    1.6875,
    1.890625,
    1.921875,
    1.859375,
    1.921875,
    1.9375,
    1.8125,
    1.8984375,
    0.9921875,
    1.9375,
    2.15625,
    1.9765625,
    1.84375,
    1.953125,
    1.90625,
    1.84375,
    1.828125,
    1.921875,
    1.921875,
    1.921875,
    1.9296875,
    1.984375,
    1.921875,
    1.890625,
    1.90625,
    1.9375,
    1.828125,
    1.90625,
    1.9453125,
    1.84375,
    1.90625,
    1.953125,
    1.890625,
    1.9296875,
    1.75,
    1.984375,
    1.9375,
    1.921875,
    1.984375,
    1.921875,
    1.90625,
    1.953125,
    1.859375,
    1.953125,
    1.84375,
    1.6953125,
    1.8046875,
    2.0,
    1.90625,
    1.7265625,
    1.9375,
    1.8203125,
    1.75,
    1.8984375,
    1.9140625,
    1.8984375,
    1.84375,
    1.796875,
    1.875,
    1.84375,
    1.953125,
    2.25,
    1.953125,
    1.984375,
    1.9375,
    1.9765625,
    1.828125,
    1.90625,
    1.890625,
    1.9609375,
    1.9375,
    1.9375,
    1.9375,
    1.875,
    1.9296875,
    1.828125,
    1.875,
    1.890625,
    1.8125,
    1.9609375,
    1.984375,
    1.859375,
    1.875,
    1.890625,
    1.90625,
    1.828125,
    1.734375,
    1.9375,
    1.9140625,
    1.8828125,
    1.921875,
    2.0,
    1.953125,
    1.90625,
    1.8828125,
    1.84375,
    1.8125,
    1.921875,
    1.9140625,
    1.9375,
    1.9375,
    1.71875,
    1.875,
    1.7578125,
    1.9453125,
    1.796875,
    1.734375,
    1.9375,
    1.7578125,
    1.921875,
    1.9140625,
    1.9375,
    1.9296875,
    1.9453125,
    1.90625,
    1.921875,
    1.9296875,
    1.9375,
    1.875,
    1.90625,
    1.75,
    1.640625,
    1.8671875,
    1.890625,
    1.90625,
    1.796875,
    1.890625,
    1.90625,
    1.9375,
    1.890625,
    1.8671875,
    1.921875,
    1.890625,
    1.8046875,
    1.921875,
    1.4140625,
    1.9140625,
    1.8515625,
    1.9609375,
    1.9296875,
    1.953125,
    1.9375,
    1.765625,
    1.75,
    1.84375,
    1.96875,
    1.90625,
    1.9375,
    2.03125,
    1.8984375,
    1.9609375,
    1.625,
    1.921875,
    1.84375,
    1.921875,
    1.9375,
    2.03125,
    1.75,
    1.9375,
    1.9375,
    1.8828125,
    1.890625,
    2.15625,
    1.96875,
    1.8125,
    1.859375,
    1.625,
    1.921875,
    2.0,
    1.6875,
    1.8984375,
    1.8046875,
    1.875,
    1.953125,
    1.8671875,
    1.84375,
    1.921875,
    1.8671875,
    1.921875,
    1.7421875,
    1.8125,
    1.90625,
    1.9296875,
    1.875,
    1.9140625,
    1.9375,
    1.828125,
    1.6171875,
    1.703125,
    1.90625,
    1.8984375,
    1.734375,
    1.8125,
    1.734375,
    1.953125,
    1.90625,
    1.84375,
    1.8671875,
    1.90625,
    1.984375,
    1.890625,
    1.78125,
    1.890625,
    1.9296875,
    1.890625,
    1.9375,
    1.90625,
    1.875,
    1.8984375,
    1.90625,
    1.8984375,
    1.8828125,
    1.84375,
    1.7890625,
    1.921875,
    1.90625,
    1.953125,
    1.96875,
    1.609375,
    1.84375,
    1.921875,
    1.921875,
    1.9609375,
    1.8671875,
    1.875,
    1.953125,
    1.953125,
    1.921875,
    1.9296875,
    1.8828125,
    1.9296875,
    1.9765625,
    1.953125,
    1.8671875,
    1.84375,
    1.7265625,
    1.953125,
    1.890625,
    1.9921875,
    1.8984375,
    1.8203125,
    1.8984375,
    1.796875,
    1.828125,
    1.6953125,
    1.9140625,
    1.859375,
    1.8125,
    1.8515625,
    1.859375,
    1.921875,
    1.828125,
    1.8671875,
    1.765625,
    1.9140625,
    1.9296875,
    1.84375,
    1.9140625,
    1.9375,
    1.953125,
    1.921875,
    1.984375,
    1.921875,
    1.78125,
    1.90625,
    1.8984375,
    1.953125,
    1.75,
    1.84375,
    1.921875,
    1.890625,
    1.859375,
    1.875,
    1.9375,
    1.8125,
    1.7421875,
    1.703125,
    1.71875,
    1.90625,
    1.875,
    1.6484375,
    1.9453125,
    1.640625,
    1.9375,
    1.921875,
    1.859375,
    1.9375,
    1.953125,
    1.90625,
    1.921875,
    2.0,
    1.96875,
    1.9296875,
    1.8046875,
    1.59375,
    1.9609375,
    1.921875,
    1.859375,
    1.9375,
    1.890625,
    1.8984375,
    1.9375,
    1.921875,
    1.9375,
    1.8984375,
    1.578125,
    1.8828125,
    1.9765625,
    1.828125,
    1.875,
    1.921875,
    1.828125,
    1.875,
    1.84375,
    2.0,
    1.953125,
    1.859375,
    1.9375,
    1.890625,
    1.875,
    2.0,
    1.828125,
    1.953125,
    1.984375,
    1.9453125,
    1.78125,
    1.953125,
    1.7890625,
    1.9453125,
    1.859375,
    1.9375,
    1.890625,
    1.9296875,
    1.8125,
    1.859375,
    1.90625,
    2.21875,
    1.9453125,
    1.96875,
    1.9296875,
    1.953125,
    1.9140625,
    1.890625,
    1.90625,
    1.796875,
    1.90625,
    1.8828125
  ],
  "final_gain_convention": "effective final-norm gain gamma = stored + 1 of the source model`s final norm, the value folded into lm_head; a drafter that enters the folded head divides by it",
  "final_gain_source": "leonsarmiento/Qwen3.8-27B-3bit-mtp-mlx language_model.model.norm.weight (effective 1+w, bf16)"
}
"#
data_chars foldChars fold

/-- Verbatim `packages/inference/src/state/persistence.worker.js` (a text import). -/
def worker : String := r#"// CPU-only persistence worker. It deliberately imports no model, MLX,
// scheduler or cache manager. The sender owns all buffers through completion.
import { parentPort } from "node:worker_threads";
import { toArrayBuffer, ptr } from "bun:ffi";
import { openSync, writeSync, closeSync, fsyncSync, renameSync, rmSync, mkdirSync, existsSync, readSync, readFileSync, readdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { dirname, join } from "node:path";

const MAGIC = "MLXBUNKV2\n";
const PREFIX_LEN = MAGIC.length + 16;
const alignUp = n => Math.ceil(n / 16384) * 16384;
const hash64 = bytes => Bun.hash(bytes).toString(16).padStart(16, "0");
let scratch = new Uint8Array(0);

function bytesOf(tensor) {
  const { pointer, shape, strides, itemSize } = tensor;
  const size = shape.reduce((a, b) => a * b, 1);
  if (!size) return new Uint8Array(0);
  // Coalesce the contiguous suffix. Most KV layouts need only a copy per
  // head to omit capacity padding, never a GPU contiguous() operation.
  let run = 1, axis = shape.length - 1;
  while (axis >= 0 && (shape[axis] === 1 || strides[axis] === run)) {
    run *= shape[axis--];
  }
  if (axis < 0) return new Uint8Array(toArrayBuffer(pointer, 0, size * itemSize));
  let lo = 0, hi = 0;
  for (let i = 0; i < shape.length; i++) {
    const end = (shape[i] - 1) * strides[i];
    lo += Math.min(0, end); hi += Math.max(0, end);
  }
  const source = new Uint8Array(toArrayBuffer(pointer + lo * itemSize, 0, (hi - lo + 1) * itemSize));
  if (scratch.length < size * itemSize) scratch = new Uint8Array(size * itemSize);
  const bytes = scratch.subarray(0, size * itemSize);
  const runBytes = run * itemSize;
  for (let row = 0; row < size / run; row++) {
    let index = row, offset = -lo;
    for (let i = axis; i >= 0; i--) {
      offset += (index % shape[i]) * strides[i];
      index = Math.floor(index / shape[i]);
    }
    bytes.set(source.subarray(offset * itemSize, offset * itemSize + runBytes), row * runBytes);
  }
  return bytes;
}

function writeAll(fd, bytes, position) {
  let offset = 0;
  while (offset < bytes.length) {
    const n = writeSync(fd, bytes, offset, bytes.length - offset, position + offset);
    if (!n) throw new Error("KV write made no progress");
    offset += n;
  }
}

function writeSnapshot({ path, header, tensors }) {
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  const headerLen = new TextEncoder().encode(JSON.stringify(header)).length;
  const dataStart = alignUp(PREFIX_LEN + headerLen);
  mkdirSync(dirname(path), { recursive: true });
  const tmp = `${path}.tmp`;
  const fd = openSync(tmp, "w");
  try {
    for (let i = 0; i < slots.length; i++) {
      const bytes = bytesOf(tensors[i]);
      if (bytes.length !== slots[i].bytes) throw new Error("KV tensor byte-length drift");
      slots[i].hash = hash64(bytes);
      writeAll(fd, bytes, dataStart + slots[i].off);
    }
    const json = new TextEncoder().encode(JSON.stringify(header));
    if (json.length !== headerLen) throw new Error("KV header byte-length drift");
    const prefix = new Uint8Array(dataStart);
    prefix.set(new TextEncoder().encode(MAGIC));
    const view = new DataView(prefix.buffer);
    view.setUint32(MAGIC.length, headerLen, true);
    view.setUint32(MAGIC.length + 4, dataStart, true);
    view.setBigUint64(MAGIC.length + 8, BigInt(Bun.hash(json)), true);
    prefix.set(json, PREFIX_LEN);
    writeAll(fd, prefix, 0);
    fsyncSync(fd);
  } catch (error) {
    closeSync(fd);
    rmSync(tmp, { force: true });
    throw error;
  }
  closeSync(fd);
  try { renameSync(tmp, path); }
  catch (error) { rmSync(tmp, { force: true }); throw error; }
}

// The block boundary resets for each leading row (e.g. attention head).
// Growing a token axis therefore leaves preceding blocks byte-identical.
function* segments(tensor, blockBytes, metrics) {
  const { pointer, shape, strides, itemSize } = tensor;
  const size = shape.reduce((a, b) => a * b, 1);
  const rowSize = shape.slice(-2).reduce((a, b) => a * b, 1);
  if (!size) return;
  let run = 1, axis = shape.length - 1;
  while (axis >= 0 && (shape[axis] === 1 || strides[axis] === run)) run *= shape[axis--];
  const limit = Math.max(1, Math.floor(blockBytes / itemSize));
  let packing = null;
  for (let start = 0; start < size;) {
    const count = Math.min(limit, rowSize - start % rowSize, size - start);
    let index = start, offset = 0;
    for (let i = shape.length - 1; i >= 0; i--) {
      offset += index % shape[i] * strides[i]; index = Math.floor(index / shape[i]);
    }
    if (count <= run - start % run) {
      yield new Uint8Array(toArrayBuffer(pointer + offset * itemSize, 0, count * itemSize));
    } else {
      if (!packing) packing = new Uint8Array(limit * itemSize);
      metrics.scratchPeak = Math.max(metrics.scratchPeak, packing.byteLength);
      const bytes = packing.subarray(0, count * itemSize);
      for (let copied = 0; copied < count;) {
        index = start + copied; offset = 0;
        for (let i = shape.length - 1; i >= 0; i--) {
          offset += index % shape[i] * strides[i]; index = Math.floor(index / shape[i]);
        }
        const n = Math.min(count - copied, run - (start + copied) % run);
        bytes.set(new Uint8Array(toArrayBuffer(pointer + offset * itemSize, 0, n * itemSize)), copied * itemSize);
        copied += n;
      }
      metrics.copiedBytes += bytes.length;
      yield bytes;
    }
    start += count;
  }
}

function writeHeader(path, header) {
  const json = new TextEncoder().encode(JSON.stringify(header));
  const prefix = new Uint8Array(PREFIX_LEN + json.length);
  prefix.set(new TextEncoder().encode(MAGIC));
  const view = new DataView(prefix.buffer);
  view.setUint32(MAGIC.length, json.length, true);
  view.setUint32(MAGIC.length + 4, prefix.length, true);
  view.setBigUint64(MAGIC.length + 8, BigInt(Bun.hash(json)), true);
  prefix.set(json, PREFIX_LEN);
  const tmp = path + ".tmp", fd = openSync(tmp, "w");
  try { writeAll(fd, prefix, 0); fsyncSync(fd); }
  finally { closeSync(fd); }
  renameSync(tmp, path);
  return prefix.length;
}

function writeBlocks({ path, header, tensors, blockBytes = 1024 * 1024, segmented = true }) {
  const metrics = { writtenBytes: 0, reusedBytes: 0, copiedBytes: 0, scratchPeak: 0 };
  const root = join(dirname(path), "blocks");
  mkdirSync(root, { recursive: true });
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  for (let i = 0; i < slots.length; i++) {
    const slot = slots[i]; slot.blocks = [];
    let bytes = 0;
    let source = tensors[i];
    let packed;
    if (!segmented) {
      packed = bytesOf(source);
      metrics.copiedBytes += packed.buffer === scratch.buffer ? packed.length : 0;
      metrics.scratchPeak = Math.max(metrics.scratchPeak, scratch.length);
      // Contiguous strides, but retain row boundaries for identical blocks.
      let stride = 1;
      const strides = Array(source.shape.length);
      for (let j = strides.length - 1; j >= 0; j--) { strides[j] = stride; stride *= source.shape[j]; }
      // No second copy; the pointer remains live until this tensor finishes.
      source = { ...source, pointer: packed.length ? Number(ptr(packed)) : 0, strides };
    }
    for (const chunk of segments(source, blockBytes, metrics)) {
      const hash = createHash("sha256").update(chunk).digest("hex");
      bytes += chunk.length;
      slot.blocks.push({ hash, bytes: chunk.length });
      const destination = join(root, hash);
      if (existsSync(destination)) { metrics.reusedBytes += chunk.length; continue; }
      const tmp = destination + ".tmp", fd = openSync(tmp, "w");
      try { writeAll(fd, chunk, 0); fsyncSync(fd); }
      finally { closeSync(fd); }
      renameSync(tmp, destination);
      metrics.writtenBytes += chunk.length;
    }
    if (bytes !== slot.bytes) throw new Error("KV tensor byte-length drift");
    // The header authenticates block order; each block authenticates bytes.
    // Avoid hashing the same tensor a second time.
    slot.hash = "";
  }
  header.formatVersion = 5;
  metrics.writtenBytes += writeHeader(path, header);
  return metrics;
}

function readAll(fd, bytes, position) {
  let offset = 0;
  while (offset < bytes.length) {
    const n = readSync(fd, bytes, offset, bytes.length - offset, position + offset);
    if (!n) throw new Error("truncated KV tensor");
    offset += n;
  }
}

// Destinations are unpublished, independently owned host allocations. No
// MLX API is called here, and the owner retains them until acknowledgement.
function readSnapshot({ path, header, pointers, verify }) {
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  const fd = header.formatVersion === 5 ? null : openSync(path, "r");
  try {
    for (let i = 0; i < slots.length; i++) {
      const slot = slots[i];
      const bytes = slot.bytes ? new Uint8Array(toArrayBuffer(pointers[i], 0, slot.bytes)) : new Uint8Array(0);
      if (header.formatVersion === 5) {
        let offset = 0;
        for (const block of slot.blocks ?? []) {
          if (!/^[a-f0-9]{64}$/.test(block.hash) || block.bytes <= 0 || offset + block.bytes > bytes.length)
            throw new Error("invalid KV block reference");
          const blockFd = openSync(join(dirname(path), "blocks", block.hash), "r");
          const target = bytes.subarray(offset, offset + block.bytes);
          try { readAll(blockFd, target, 0); } finally { closeSync(blockFd); }
          if (verify && createHash("sha256").update(target).digest("hex") !== block.hash)
            throw new Error("KV block hash mismatch");
          offset += block.bytes;
        }
        if (offset !== bytes.length) throw new Error("incomplete KV tensor blocks");
      } else {
        readAll(fd, bytes, header.dataStart + slot.off);
        if (verify && hash64(bytes) !== slot.hash) throw new Error("KV tensor hash mismatch");
      }
    }
  } finally { if (fd !== null) closeSync(fd); }
}

// Serialized with writes: an in-flight manifest cannot lose its blocks.
// Only unreferenced content is collected; shared prefixes remain on SSD.
function collectBlocks({ root }) {
  if (!existsSync(root)) return;
  for (const ns of readdirSync(root, { withFileTypes: true })) {
    if (!ns.isDirectory()) continue;
    const dir = join(root, ns.name), blocks = join(dir, "blocks");
    if (!existsSync(blocks)) continue;
    const live = new Set();
    for (const file of readdirSync(dir)) {
      if (!file.endsWith(".mlxkv")) continue;
      const fd = openSync(join(dir, file), "r");
      try {
        const prefix = new Uint8Array(PREFIX_LEN); readAll(fd, prefix, 0);
        const view = new DataView(prefix.buffer), json = new Uint8Array(view.getUint32(MAGIC.length, true));
        readAll(fd, json, PREFIX_LEN);
        if (BigInt(Bun.hash(json)) !== view.getBigUint64(MAGIC.length + 8, true)) continue;
        const header = JSON.parse(new TextDecoder().decode(json));
        for (const entry of [...header.caches, ...(header.attachments ?? [])])
          for (const slot of entry.tensors) for (const block of slot.blocks ?? []) live.add(block.hash);
      } finally { closeSync(fd); }
    }
    for (const file of readdirSync(blocks))
      if (!live.has(file)) rmSync(join(blocks, file), { force: true });
  }
}

parentPort.on("message", data => {
  try {
    const started = performance.now();
    const metrics = data.operation === "read" ? readSnapshot(data)
      : data.operation === "collect" ? collectBlocks(data)
      : data.layout === "blocks" ? writeBlocks(data) : writeSnapshot(data);
    parentPort.postMessage({ id: data.id, metrics: { ...metrics, elapsedMs: performance.now() - started } });
  } catch (error) {
    parentPort.postMessage({ id: data.id, error: String(error) });
  }
});
"#
data_chars workerChars worker

/-- Verbatim JSON header of `model-00001-of-00006.safetensors` (bytes 8 … 16520). -/
def header0 : String := r#"{"__metadata__":{"format":"mlx"},"lm_head.biases":{"data_offsets":[1298714336,1338445536],"dtype":"BF16","shape":[248320,80]},"lm_head.scales":{"data_offsets":[919635712,959366912],"dtype":"BF16","shape":[248320,80]},"lm_head.weight":{"data_offsets":[221309184,857008384],"dtype":"U32","shape":[248320,640]},"model.language_model.embed_tokens.biases":{"data_offsets":[1106314624,1146045824],"dtype":"BF16","shape":[248320,80]},"model.language_model.embed_tokens.scales":{"data_offsets":[1066419488,1106150688],"dtype":"BF16","shape":[248320,80]},"model.language_model.embed_tokens.weight":{"data_offsets":[1341231424,1976930624],"dtype":"U32","shape":[248320,640]},"model.language_model.layers.0.input_layernorm.weight":{"data_offsets":[1066409248,1066419488],"dtype":"BF16","shape":[5120]},"model.language_model.layers.0.linear_attn.A_log":{"data_offsets":[1106150688,1106150784],"dtype":"BF16","shape":[48]},"model.language_model.layers.0.linear_attn.conv1d.weight":{"data_offsets":[971301824,971383744],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.0.linear_attn.dt_bias":{"data_offsets":[971391424,971391520],"dtype":"BF16","shape":[48]},"model.language_model.layers.0.linear_attn.in_proj_a.biases":{"data_offsets":[2011337024,2011344704],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.0.linear_attn.in_proj_a.scales":{"data_offsets":[1066401568,1066409248],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.0.linear_attn.in_proj_a.weight":{"data_offsets":[2052632384,2052755264],"dtype":"U32","shape":[48,640]},"model.language_model.layers.0.linear_attn.in_proj_b.biases":{"data_offsets":[1063444768,1063452448],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.0.linear_attn.in_proj_b.scales":{"data_offsets":[880472320,880480000],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.0.linear_attn.in_proj_b.weight":{"data_offsets":[1196800896,1196923776],"dtype":"U32","shape":[48,640]},"model.language_model.layers.0.linear_attn.in_proj_qkv.biases":{"data_offsets":[1046077472,1047715872],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.0.linear_attn.in_proj_qkv.scales":{"data_offsets":[1195117440,1196755840],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.0.linear_attn.in_proj_qkv.weight":{"data_offsets":[2086206784,2112421184],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.0.linear_attn.in_proj_z.biases":{"data_offsets":[1219370208,1220353248],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.0.linear_attn.in_proj_z.scales":{"data_offsets":[1045094432,1046077472],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.0.linear_attn.in_proj_z.weight":{"data_offsets":[1047715872,1063444512],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.0.linear_attn.norm.weight":{"data_offsets":[1196923776,1196924032],"dtype":"BF16","shape":[128]},"model.language_model.layers.0.linear_attn.out_proj.biases":{"data_offsets":[993968672,994951712],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.0.linear_attn.out_proj.scales":{"data_offsets":[1028382752,1029365792],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.0.linear_attn.out_proj.weight":{"data_offsets":[1029365792,1045094432],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.0.mlp.down_proj.scales":{"data_offsets":[993933856,993968672],"dtype":"F16","shape":[17408]},"model.language_model.layers.0.mlp.down_proj.weight":{"data_offsets":[2012983104,2035265344],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.0.mlp.gate_proj.scales":{"data_offsets":[993776160,993810976],"dtype":"F16","shape":[17408]},"model.language_model.layers.0.mlp.gate_proj.weight":{"data_offsets":[1196924032,1219206272],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.0.mlp.up_proj.scales":{"data_offsets":[1146063744,1146098560],"dtype":"F16","shape":[17408]},"model.language_model.layers.0.mlp.up_proj.weight":{"data_offsets":[971493920,993776160],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.0.post_attention_layernorm.weight":{"data_offsets":[971483680,971493920],"dtype":"BF16","shape":[5120]},"model.language_model.layers.1.input_layernorm.weight":{"data_offsets":[971473440,971483680],"dtype":"BF16","shape":[5120]},"model.language_model.layers.1.linear_attn.A_log":{"data_offsets":[1341230816,1341230912],"dtype":"BF16","shape":[48]},"model.language_model.layers.1.linear_attn.conv1d.weight":{"data_offsets":[971391520,971473440],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.1.linear_attn.dt_bias":{"data_offsets":[971301728,971301824],"dtype":"BF16","shape":[48]},"model.language_model.layers.1.linear_attn.in_proj_a.biases":{"data_offsets":[959497568,959505248],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.1.linear_attn.in_proj_a.scales":{"data_offsets":[971383744,971391424],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.1.linear_attn.in_proj_a.weight":{"data_offsets":[993810976,993933856],"dtype":"U32","shape":[48,640]},"model.language_model.layers.1.linear_attn.in_proj_b.biases":{"data_offsets":[959366912,959374592],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.1.linear_attn.in_proj_b.scales":{"data_offsets":[2052765504,2052773184],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.1.linear_attn.in_proj_b.weight":{"data_offsets":[959374688,959497568],"dtype":"U32","shape":[48,640]},"model.language_model.layers.1.linear_attn.in_proj_qkv.biases":{"data_offsets":[917997312,919635712],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.1.linear_attn.in_proj_qkv.scales":{"data_offsets":[195742464,197380864],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.1.linear_attn.in_proj_qkv.weight":{"data_offsets":[2113527104,2133187904],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.1.linear_attn.in_proj_z.biases":{"data_offsets":[1160700800,1161683840],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.1.linear_attn.in_proj_z.scales":{"data_offsets":[916020992,917004032],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.1.linear_attn.in_proj_z.weight":{"data_offsets":[1148894080,1160690560],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.1.linear_attn.norm.weight":{"data_offsets":[1063444512,1063444768],"dtype":"BF16","shape":[128]},"model.language_model.layers.1.linear_attn.out_proj.biases":{"data_offsets":[914054912,915037952],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.1.linear_attn.out_proj.scales":{"data_offsets":[917004032,917987072],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.1.linear_attn.out_proj.weight":{"data_offsets":[2035265344,2050993984],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.1.mlp.down_proj.scales":{"data_offsets":[880480000,880514816],"dtype":"F16","shape":[17408]},"model.language_model.layers.1.mlp.down_proj.weight":{"data_offsets":[1977913664,2011337024],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.1.mlp.gate_proj.scales":{"data_offsets":[857008384,857043200],"dtype":"F16","shape":[17408]},"model.language_model.layers.1.mlp.gate_proj.weight":{"data_offsets":[857207040,879489280],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.1.mlp.up_proj.scales":{"data_offsets":[1222319328,1222354144],"dtype":"F16","shape":[17408]},"model.language_model.layers.1.mlp.up_proj.weight":{"data_offsets":[197388544,219670784],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.1.post_attention_layernorm.weight":{"data_offsets":[2086196544,2086206784],"dtype":"BF16","shape":[5120]},"model.language_model.layers.2.input_layernorm.weight":{"data_offsets":[917987072,917997312],"dtype":"BF16","shape":[5120]},"model.language_model.layers.2.linear_attn.A_log":{"data_offsets":[959374592,959374688],"dtype":"BF16","shape":[48]},"model.language_model.layers.2.linear_attn.conv1d.weight":{"data_offsets":[913938176,914020096],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.2.linear_attn.dt_bias":{"data_offsets":[1219370112,1219370208],"dtype":"BF16","shape":[48]},"model.language_model.layers.2.linear_attn.in_proj_a.biases":{"data_offsets":[1146056064,1146063744],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.2.linear_attn.in_proj_a.scales":{"data_offsets":[197380864,197388544],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.2.linear_attn.in_proj_a.weight":{"data_offsets":[2112421184,2112544064],"dtype":"U32","shape":[48,640]},"model.language_model.layers.2.linear_attn.in_proj_b.biases":{"data_offsets":[1028375072,1028382752],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.2.linear_attn.in_proj_b.scales":{"data_offsets":[195611904,195619584],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.2.linear_attn.in_proj_b.weight":{"data_offsets":[195619584,195742464],"dtype":"U32","shape":[48,640]},"model.language_model.layers.2.linear_attn.in_proj_qkv.biases":{"data_offsets":[219670784,221309184],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.2.linear_attn.in_proj_qkv.scales":{"data_offsets":[193973504,195611904],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.2.linear_attn.in_proj_qkv.weight":{"data_offsets":[1244964576,1264625376],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.2.linear_attn.in_proj_z.biases":{"data_offsets":[1976930624,1977913664],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.2.linear_attn.in_proj_z.scales":{"data_offsets":[1065418528,1066401568],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.2.linear_attn.in_proj_z.weight":{"data_offsets":[182142208,193938688],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.2.linear_attn.norm.weight":{"data_offsets":[182141952,182142208],"dtype":"BF16","shape":[128]},"model.language_model.layers.2.linear_attn.out_proj.biases":{"data_offsets":[164447232,165430272],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.2.linear_attn.out_proj.scales":{"data_offsets":[165430272,166413312],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.2.linear_attn.out_proj.weight":{"data_offsets":[166413312,182141952],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.2.mlp.down_proj.scales":{"data_offsets":[193938688,193973504],"dtype":"F16","shape":[17408]},"model.language_model.layers.2.mlp.down_proj.weight":{"data_offsets":[131023872,164447232],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.2.mlp.gate_proj.scales":{"data_offsets":[914020096,914054912],"dtype":"F16","shape":[17408]},"model.language_model.layers.2.mlp.gate_proj.weight":{"data_offsets":[108741632,131023872],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.2.mlp.up_proj.scales":{"data_offsets":[86424576,86459392],"dtype":"F16","shape":[17408]},"model.language_model.layers.2.mlp.up_proj.weight":{"data_offsets":[86459392,108741632],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.2.post_attention_layernorm.weight":{"data_offsets":[1146045824,1146056064],"dtype":"BF16","shape":[5120]},"model.language_model.layers.3.input_layernorm.weight":{"data_offsets":[86414336,86424576],"dtype":"BF16","shape":[5120]},"model.language_model.layers.3.mlp.down_proj.scales":{"data_offsets":[1196766080,1196800896],"dtype":"F16","shape":[17408]},"model.language_model.layers.3.mlp.down_proj.weight":{"data_offsets":[52990976,86414336],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.3.mlp.gate_proj.scales":{"data_offsets":[52956160,52990976],"dtype":"F16","shape":[17408]},"model.language_model.layers.3.mlp.gate_proj.weight":{"data_offsets":[994951712,1028375072],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.3.mlp.up_proj.scales":{"data_offsets":[19497984,19532800],"dtype":"F16","shape":[17408]},"model.language_model.layers.3.mlp.up_proj.weight":{"data_offsets":[19532800,52956160],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.3.post_attention_layernorm.weight":{"data_offsets":[1196755840,1196766080],"dtype":"BF16","shape":[5120]},"model.language_model.layers.3.self_attn.k_norm.weight":{"data_offsets":[19497472,19497984],"dtype":"BF16","shape":[256]},"model.language_model.layers.3.self_attn.k_proj.biases":{"data_offsets":[16712192,16876032],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.3.self_attn.k_proj.scales":{"data_offsets":[1222354656,1222518496],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.3.self_attn.k_proj.weight":{"data_offsets":[16876032,19497472],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.3.self_attn.o_proj.biases":{"data_offsets":[2112544064,2113527104],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.3.self_attn.o_proj.scales":{"data_offsets":[512,983552],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.3.self_attn.o_proj.weight":{"data_offsets":[983552,16712192],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.3.self_attn.q_norm.weight":{"data_offsets":[0,512],"dtype":"BF16","shape":[256]},"mtp.fc.biases":{"data_offsets":[2050993984,2052632384],"dtype":"BF16","shape":[5120,160]},"mtp.fc.scales":{"data_offsets":[2011344704,2012983104],"dtype":"BF16","shape":[5120,160]},"mtp.fc.weight":{"data_offsets":[1225303776,1244964576],"dtype":"U32","shape":[5120,960]},"mtp.layers.0.input_layernorm.weight":{"data_offsets":[1264625376,1264635616],"dtype":"BF16","shape":[5120]},"mtp.layers.0.mlp.down_proj.biases":{"data_offsets":[1338445536,1341230816],"dtype":"BF16","shape":[5120,272]},"mtp.layers.0.mlp.down_proj.scales":{"data_offsets":[1295765216,1298550496],"dtype":"BF16","shape":[5120,272]},"mtp.layers.0.mlp.down_proj.weight":{"data_offsets":[2052773184,2086196544],"dtype":"U32","shape":[5120,1632]},"mtp.layers.0.mlp.gate_proj.biases":{"data_offsets":[1292979936,1295765216],"dtype":"BF16","shape":[17408,80]},"mtp.layers.0.mlp.gate_proj.scales":{"data_offsets":[1146098560,1148883840],"dtype":"BF16","shape":[17408,80]},"mtp.layers.0.mlp.gate_proj.weight":{"data_offsets":[880514816,913938176],"dtype":"U32","shape":[17408,480]},"mtp.layers.0.mlp.up_proj.biases":{"data_offsets":[1222518496,1225303776],"dtype":"BF16","shape":[17408,80]},"mtp.layers.0.mlp.up_proj.scales":{"data_offsets":[1264635616,1267420896],"dtype":"BF16","shape":[17408,80]},"mtp.layers.0.mlp.up_proj.weight":{"data_offsets":[1161683840,1195107200],"dtype":"U32","shape":[17408,480]},"mtp.layers.0.post_attention_layernorm.weight":{"data_offsets":[2052755264,2052765504],"dtype":"BF16","shape":[5120]},"mtp.layers.0.self_attn.k_norm.weight":{"data_offsets":[1341230912,1341231424],"dtype":"BF16","shape":[256]},"mtp.layers.0.self_attn.k_proj.biases":{"data_offsets":[1298550496,1298714336],"dtype":"BF16","shape":[1024,80]},"mtp.layers.0.self_attn.k_proj.scales":{"data_offsets":[1106150784,1106314624],"dtype":"BF16","shape":[1024,80]},"mtp.layers.0.self_attn.k_proj.weight":{"data_offsets":[2133187904,2135153984],"dtype":"U32","shape":[1024,480]},"mtp.layers.0.self_attn.o_proj.biases":{"data_offsets":[915037952,916020992],"dtype":"BF16","shape":[5120,96]},"mtp.layers.0.self_attn.o_proj.scales":{"data_offsets":[879489280,880472320],"dtype":"BF16","shape":[5120,96]},"mtp.layers.0.self_attn.o_proj.weight":{"data_offsets":[959505248,971301728],"dtype":"U32","shape":[5120,576]},"mtp.layers.0.self_attn.q_norm.weight":{"data_offsets":[1222354144,1222354656],"dtype":"BF16","shape":[256]},"mtp.layers.0.self_attn.q_proj.biases":{"data_offsets":[1220353248,1222319328],"dtype":"BF16","shape":[12288,80]},"mtp.layers.0.self_attn.q_proj.scales":{"data_offsets":[1267420896,1269386976],"dtype":"BF16","shape":[12288,80]},"mtp.layers.0.self_attn.q_proj.weight":{"data_offsets":[1269386976,1292979936],"dtype":"U32","shape":[12288,480]},"mtp.layers.0.self_attn.v_proj.biases":{"data_offsets":[857043200,857207040],"dtype":"BF16","shape":[1024,80]},"mtp.layers.0.self_attn.v_proj.scales":{"data_offsets":[1219206272,1219370112],"dtype":"BF16","shape":[1024,80]},"mtp.layers.0.self_attn.v_proj.weight":{"data_offsets":[1063452448,1065418528],"dtype":"U32","shape":[1024,480]},"mtp.norm.weight":{"data_offsets":[1195107200,1195117440],"dtype":"BF16","shape":[5120]},"mtp.pre_fc_norm_embedding.weight":{"data_offsets":[1160690560,1160700800],"dtype":"BF16","shape":[5120]},"mtp.pre_fc_norm_hidden.weight":{"data_offsets":[1148883840,1148894080],"dtype":"BF16","shape":[5120]}}"#
data_chars header0Chars header0

/-- Verbatim JSON header of `model-00002-of-00006.safetensors` (bytes 8 … 69578). -/
def header1 : String := r#"{"__metadata__":{"format":"mlx"},"model.language_model.layers.10.input_layernorm.weight":{"data_offsets":[756484288,756494528],"dtype":"BF16","shape":[5120]},"model.language_model.layers.10.linear_attn.A_log":{"data_offsets":[2021772608,2021772704],"dtype":"BF16","shape":[48]},"model.language_model.layers.10.linear_attn.conv1d.weight":{"data_offsets":[706850752,706932672],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.10.linear_attn.dt_bias":{"data_offsets":[706850656,706850752],"dtype":"BF16","shape":[48]},"model.language_model.layers.10.linear_attn.in_proj_a.biases":{"data_offsets":[2113000064,2113007744],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.10.linear_attn.in_proj_a.scales":{"data_offsets":[2053068096,2053075776],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.10.linear_attn.in_proj_a.weight":{"data_offsets":[673304416,673427296],"dtype":"U32","shape":[48,640]},"model.language_model.layers.10.linear_attn.in_proj_b.biases":{"data_offsets":[1846791392,1846799072],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.10.linear_attn.in_proj_b.scales":{"data_offsets":[673173856,673181536],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.10.linear_attn.in_proj_b.weight":{"data_offsets":[2094944384,2095067264],"dtype":"U32","shape":[48,640]},"model.language_model.layers.10.linear_attn.in_proj_qkv.biases":{"data_offsets":[651872352,653510752],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.10.linear_attn.in_proj_qkv.scales":{"data_offsets":[800755136,802393536],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.10.linear_attn.in_proj_qkv.weight":{"data_offsets":[653513056,673173856],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.10.linear_attn.in_proj_z.biases":{"data_offsets":[1082822048,1083805088],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.10.linear_attn.in_proj_z.scales":{"data_offsets":[1661910880,1662893920],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.10.linear_attn.in_proj_z.weight":{"data_offsets":[630159456,641955936],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.10.linear_attn.norm.weight":{"data_offsets":[1126752224,1126752480],"dtype":"BF16","shape":[128]},"model.language_model.layers.10.linear_attn.out_proj.biases":{"data_offsets":[1253625664,1254608704],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.10.linear_attn.out_proj.scales":{"data_offsets":[1174479360,1175462400],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.10.linear_attn.out_proj.weight":{"data_offsets":[584939616,596736096],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.10.mlp.down_proj.scales":{"data_offsets":[1490348416,1490383232],"dtype":"F16","shape":[17408]},"model.language_model.layers.10.mlp.down_proj.weight":{"data_offsets":[596736096,630159456],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.10.mlp.gate_proj.scales":{"data_offsets":[561639520,561674336],"dtype":"F16","shape":[17408]},"model.language_model.layers.10.mlp.gate_proj.weight":{"data_offsets":[562657376,584939616],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.10.mlp.up_proj.scales":{"data_offsets":[1412751168,1412785984],"dtype":"F16","shape":[17408]},"model.language_model.layers.10.mlp.up_proj.weight":{"data_offsets":[539357280,561639520],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.10.post_attention_layernorm.weight":{"data_offsets":[1534453696,1534463936],"dtype":"BF16","shape":[5120]},"model.language_model.layers.11.input_layernorm.weight":{"data_offsets":[1166490208,1166500448],"dtype":"BF16","shape":[5120]},"model.language_model.layers.11.mlp.down_proj.scales":{"data_offsets":[1126717408,1126752224],"dtype":"F16","shape":[17408]},"model.language_model.layers.11.mlp.down_proj.weight":{"data_offsets":[517072640,539354880],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.11.mlp.gate_proj.scales":{"data_offsets":[517037824,517072640],"dtype":"F16","shape":[17408]},"model.language_model.layers.11.mlp.gate_proj.weight":{"data_offsets":[909144928,931427168],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.11.mlp.up_proj.scales":{"data_offsets":[706932672,706967488],"dtype":"F16","shape":[17408]},"model.language_model.layers.11.mlp.up_proj.weight":{"data_offsets":[494752768,517035008],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.11.post_attention_layernorm.weight":{"data_offsets":[1412724800,1412735040],"dtype":"BF16","shape":[5120]},"model.language_model.layers.11.self_attn.k_norm.weight":{"data_offsets":[517037312,517037824],"dtype":"BF16","shape":[256]},"model.language_model.layers.11.self_attn.k_proj.biases":{"data_offsets":[1066710528,1066874368],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.11.self_attn.k_proj.scales":{"data_offsets":[491967488,492131328],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.11.self_attn.k_proj.weight":{"data_offsets":[492131328,494752768],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.11.self_attn.o_proj.biases":{"data_offsets":[488330240,489313280],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.11.self_attn.o_proj.scales":{"data_offsets":[908161888,909144928],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.11.self_attn.o_proj.weight":{"data_offsets":[1433396704,1449125344],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.11.self_attn.q_norm.weight":{"data_offsets":[1464368864,1464369376],"dtype":"BF16","shape":[256]},"model.language_model.layers.11.self_attn.q_proj.biases":{"data_offsets":[1588255584,1590221664],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.11.self_attn.q_proj.scales":{"data_offsets":[486364160,488330240],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.11.self_attn.q_proj.weight":{"data_offsets":[1502958464,1534415744],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.11.self_attn.v_proj.biases":{"data_offsets":[1938479424,1938643264],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.11.self_attn.v_proj.scales":{"data_offsets":[1178123520,1178287360],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.11.self_attn.v_proj.weight":{"data_offsets":[483742720,486364160],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.12.input_layernorm.weight":{"data_offsets":[483732480,483742720],"dtype":"BF16","shape":[5120]},"model.language_model.layers.12.linear_attn.A_log":{"data_offsets":[483732384,483732480],"dtype":"BF16","shape":[48]},"model.language_model.layers.12.linear_attn.conv1d.weight":{"data_offsets":[483650464,483732384],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.12.linear_attn.dt_bias":{"data_offsets":[483650368,483650464],"dtype":"BF16","shape":[48]},"model.language_model.layers.12.linear_attn.in_proj_a.biases":{"data_offsets":[1938456224,1938463904],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.12.linear_attn.in_proj_a.scales":{"data_offsets":[483396928,483404608],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.12.linear_attn.in_proj_a.weight":{"data_offsets":[483404608,483527488],"dtype":"U32","shape":[48,640]},"model.language_model.layers.12.linear_attn.in_proj_b.biases":{"data_offsets":[1412792896,1412800576],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.12.linear_attn.in_proj_b.scales":{"data_offsets":[483266368,483274048],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.12.linear_attn.in_proj_b.weight":{"data_offsets":[483274048,483396928],"dtype":"U32","shape":[48,640]},"model.language_model.layers.12.linear_attn.in_proj_qkv.biases":{"data_offsets":[461967168,463605568],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.12.linear_attn.in_proj_qkv.scales":{"data_offsets":[2003909440,2005547840],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.12.linear_attn.in_proj_qkv.weight":{"data_offsets":[463605568,483266368],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.12.linear_attn.in_proj_z.biases":{"data_offsets":[448204608,449187648],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.12.linear_attn.in_proj_z.scales":{"data_offsets":[449187648,450170688],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.12.linear_attn.in_proj_z.weight":{"data_offsets":[450170688,461967168],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.12.linear_attn.norm.weight":{"data_offsets":[448204352,448204608],"dtype":"BF16","shape":[128]},"model.language_model.layers.12.linear_attn.out_proj.biases":{"data_offsets":[447221312,448204352],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.12.linear_attn.out_proj.scales":{"data_offsets":[1139332320,1140315360],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.12.linear_attn.out_proj.weight":{"data_offsets":[1770129632,1781926112],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.12.mlp.down_proj.scales":{"data_offsets":[413763136,413797952],"dtype":"F16","shape":[17408]},"model.language_model.layers.12.mlp.down_proj.weight":{"data_offsets":[413797952,447221312],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.12.mlp.gate_proj.scales":{"data_offsets":[388824640,388859456],"dtype":"F16","shape":[17408]},"model.language_model.layers.12.mlp.gate_proj.weight":{"data_offsets":[391480896,413763136],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.12.mlp.up_proj.scales":{"data_offsets":[1593762912,1593797728],"dtype":"F16","shape":[17408]},"model.language_model.layers.12.mlp.up_proj.weight":{"data_offsets":[1467060704,1489342944],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.12.post_attention_layernorm.weight":{"data_offsets":[1003496704,1003506944],"dtype":"BF16","shape":[5120]},"model.language_model.layers.13.input_layernorm.weight":{"data_offsets":[2082342624,2082352864],"dtype":"BF16","shape":[5120]},"model.language_model.layers.13.linear_attn.A_log":{"data_offsets":[388824544,388824640],"dtype":"BF16","shape":[48]},"model.language_model.layers.13.linear_attn.conv1d.weight":{"data_offsets":[388742624,388824544],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.13.linear_attn.dt_bias":{"data_offsets":[388742528,388742624],"dtype":"BF16","shape":[48]},"model.language_model.layers.13.linear_attn.in_proj_a.biases":{"data_offsets":[1314857376,1314865056],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.13.linear_attn.in_proj_a.scales":{"data_offsets":[388611968,388619648],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.13.linear_attn.in_proj_a.weight":{"data_offsets":[388619648,388742528],"dtype":"U32","shape":[48,640]},"model.language_model.layers.13.linear_attn.in_proj_b.biases":{"data_offsets":[388561792,388569472],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.13.linear_attn.in_proj_b.scales":{"data_offsets":[388604288,388611968],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.13.linear_attn.in_proj_b.weight":{"data_offsets":[1552345280,1552468160],"dtype":"U32","shape":[48,640]},"model.language_model.layers.13.linear_attn.in_proj_qkv.biases":{"data_offsets":[386923392,388561792],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.13.linear_attn.in_proj_qkv.scales":{"data_offsets":[756499136,758137536],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.13.linear_attn.in_proj_qkv.weight":{"data_offsets":[1393049408,1412710208],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.13.linear_attn.in_proj_z.biases":{"data_offsets":[1927503424,1928486464],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.13.linear_attn.in_proj_z.scales":{"data_offsets":[1489345248,1490328288],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.13.linear_attn.in_proj_z.weight":{"data_offsets":[1369444928,1381241408],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.13.linear_attn.norm.weight":{"data_offsets":[386923136,386923392],"dtype":"BF16","shape":[128]},"model.language_model.layers.13.linear_attn.out_proj.biases":{"data_offsets":[1868549184,1869532224],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.13.linear_attn.out_proj.scales":{"data_offsets":[374143616,375126656],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.13.linear_attn.out_proj.weight":{"data_offsets":[375126656,386923136],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.13.mlp.down_proj.scales":{"data_offsets":[374108800,374143616],"dtype":"F16","shape":[17408]},"model.language_model.layers.13.mlp.down_proj.weight":{"data_offsets":[1083825472,1106107712],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.13.mlp.gate_proj.scales":{"data_offsets":[372107904,372142720],"dtype":"F16","shape":[17408]},"model.language_model.layers.13.mlp.gate_proj.weight":{"data_offsets":[1324650048,1346932288],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.13.mlp.up_proj.scales":{"data_offsets":[1422716992,1422751808],"dtype":"F16","shape":[17408]},"model.language_model.layers.13.mlp.up_proj.weight":{"data_offsets":[2054743360,2077025600],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.13.post_attention_layernorm.weight":{"data_offsets":[1254608704,1254618944],"dtype":"BF16","shape":[5120]},"model.language_model.layers.14.input_layernorm.weight":{"data_offsets":[372097664,372107904],"dtype":"BF16","shape":[5120]},"model.language_model.layers.14.linear_attn.A_log":{"data_offsets":[372097568,372097664],"dtype":"BF16","shape":[48]},"model.language_model.layers.14.linear_attn.conv1d.weight":{"data_offsets":[779852736,779934656],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.14.linear_attn.dt_bias":{"data_offsets":[1928523584,1928523680],"dtype":"BF16","shape":[48]},"model.language_model.layers.14.linear_attn.in_proj_a.biases":{"data_offsets":[372089888,372097568],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.14.linear_attn.in_proj_a.scales":{"data_offsets":[1412717120,1412724800],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.14.linear_attn.in_proj_a.weight":{"data_offsets":[483527488,483650368],"dtype":"U32","shape":[48,640]},"model.language_model.layers.14.linear_attn.in_proj_b.biases":{"data_offsets":[959268960,959276640],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.14.linear_attn.in_proj_b.scales":{"data_offsets":[1359513920,1359521600],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.14.linear_attn.in_proj_b.weight":{"data_offsets":[371803168,371926048],"dtype":"U32","shape":[48,640]},"model.language_model.layers.14.linear_attn.in_proj_qkv.biases":{"data_offsets":[2053104960,2054743360],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.14.linear_attn.in_proj_qkv.scales":{"data_offsets":[350503968,352142368],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.14.linear_attn.in_proj_qkv.weight":{"data_offsets":[352142368,371803168],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.14.linear_attn.in_proj_z.biases":{"data_offsets":[561674336,562657376],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.14.linear_attn.in_proj_z.scales":{"data_offsets":[337724448,338707488],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.14.linear_attn.in_proj_z.weight":{"data_offsets":[338707488,350503968],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.14.linear_attn.norm.weight":{"data_offsets":[1603843936,1603844192],"dtype":"BF16","shape":[128]},"model.language_model.layers.14.linear_attn.out_proj.biases":{"data_offsets":[323961888,324944928],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.14.linear_attn.out_proj.scales":{"data_offsets":[324944928,325927968],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.14.linear_attn.out_proj.weight":{"data_offsets":[325927968,337724448],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.14.mlp.down_proj.scales":{"data_offsets":[290503712,290538528],"dtype":"F16","shape":[17408]},"model.language_model.layers.14.mlp.down_proj.weight":{"data_offsets":[290538528,323961888],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.14.mlp.gate_proj.scales":{"data_offsets":[1106126912,1106161728],"dtype":"F16","shape":[17408]},"model.language_model.layers.14.mlp.gate_proj.weight":{"data_offsets":[1639626336,1661908576],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.14.mlp.up_proj.scales":{"data_offsets":[1928488768,1928523584],"dtype":"F16","shape":[17408]},"model.language_model.layers.14.mlp.up_proj.weight":{"data_offsets":[268221472,290503712],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.14.post_attention_layernorm.weight":{"data_offsets":[1422760416,1422770656],"dtype":"BF16","shape":[5120]},"model.language_model.layers.15.input_layernorm.weight":{"data_offsets":[234777632,234787872],"dtype":"BF16","shape":[5120]},"model.language_model.layers.15.mlp.down_proj.scales":{"data_offsets":[1178289664,1178324480],"dtype":"F16","shape":[17408]},"model.language_model.layers.15.mlp.down_proj.weight":{"data_offsets":[212495392,234777632],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.15.mlp.gate_proj.scales":{"data_offsets":[1464369376,1464404192],"dtype":"F16","shape":[17408]},"model.language_model.layers.15.mlp.gate_proj.weight":{"data_offsets":[234798112,268221472],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.15.mlp.up_proj.scales":{"data_offsets":[190170656,190205472],"dtype":"F16","shape":[17408]},"model.language_model.layers.15.mlp.up_proj.weight":{"data_offsets":[190213152,212495392],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.15.post_attention_layernorm.weight":{"data_offsets":[234787872,234798112],"dtype":"BF16","shape":[5120]},"model.language_model.layers.15.self_attn.k_norm.weight":{"data_offsets":[190170144,190170656],"dtype":"BF16","shape":[256]},"model.language_model.layers.15.self_attn.k_proj.biases":{"data_offsets":[187221024,187384864],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.15.self_attn.k_proj.scales":{"data_offsets":[187384864,187548704],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.15.self_attn.k_proj.weight":{"data_offsets":[187548704,190170144],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.15.self_attn.o_proj.biases":{"data_offsets":[799769792,800752832],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.15.self_attn.o_proj.scales":{"data_offsets":[186237984,187221024],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.15.self_attn.o_proj.weight":{"data_offsets":[802475456,818204096],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.15.self_attn.q_norm.weight":{"data_offsets":[186237472,186237984],"dtype":"BF16","shape":[256]},"model.language_model.layers.15.self_attn.q_proj.biases":{"data_offsets":[152814112,154780192],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.15.self_attn.q_proj.scales":{"data_offsets":[372142720,374108800],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.15.self_attn.q_proj.weight":{"data_offsets":[154780192,186237472],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.15.self_attn.v_proj.biases":{"data_offsets":[371926048,372089888],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.15.self_attn.v_proj.scales":{"data_offsets":[1880151360,1880315200],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.15.self_attn.v_proj.weight":{"data_offsets":[388859456,391480896],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.16.input_layernorm.weight":{"data_offsets":[941361248,941371488],"dtype":"BF16","shape":[5120]},"model.language_model.layers.16.linear_attn.A_log":{"data_offsets":[66345216,66345312],"dtype":"BF16","shape":[48]},"model.language_model.layers.16.linear_attn.conv1d.weight":{"data_offsets":[754757056,754838976],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.16.linear_attn.dt_bias":{"data_offsets":[114594144,114594240],"dtype":"BF16","shape":[48]},"model.language_model.layers.16.linear_attn.in_proj_a.biases":{"data_offsets":[66329856,66337536],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.16.linear_attn.in_proj_a.scales":{"data_offsets":[66337536,66345216],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.16.linear_attn.in_proj_a.weight":{"data_offsets":[673181536,673304416],"dtype":"U32","shape":[48,640]},"model.language_model.layers.16.linear_attn.in_proj_b.biases":{"data_offsets":[66191616,66199296],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.16.linear_attn.in_proj_b.scales":{"data_offsets":[66199296,66206976],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.16.linear_attn.in_proj_b.weight":{"data_offsets":[66206976,66329856],"dtype":"U32","shape":[48,640]},"model.language_model.layers.16.linear_attn.in_proj_qkv.biases":{"data_offsets":[1322827680,1324466080],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.16.linear_attn.in_proj_qkv.scales":{"data_offsets":[2018153280,2019791680],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.16.linear_attn.in_proj_qkv.weight":{"data_offsets":[46530816,66191616],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.16.linear_attn.in_proj_z.biases":{"data_offsets":[1809723872,1810706912],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.16.linear_attn.in_proj_z.scales":{"data_offsets":[2122924160,2123907200],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.16.linear_attn.in_proj_z.weight":{"data_offsets":[768053952,779850432],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.16.linear_attn.norm.weight":{"data_offsets":[46530560,46530816],"dtype":"BF16","shape":[128]},"model.language_model.layers.16.linear_attn.out_proj.biases":{"data_offsets":[44564480,45547520],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.16.linear_attn.out_proj.scales":{"data_offsets":[45547520,46530560],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.16.linear_attn.out_proj.weight":{"data_offsets":[971858784,983655264],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.16.mlp.down_proj.scales":{"data_offsets":[2018118464,2018153280],"dtype":"F16","shape":[17408]},"model.language_model.layers.16.mlp.down_proj.weight":{"data_offsets":[22282240,44564480],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.16.mlp.gate_proj.scales":{"data_offsets":[1272500288,1272535104],"dtype":"F16","shape":[17408]},"model.language_model.layers.16.mlp.gate_proj.weight":{"data_offsets":[0,22282240],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.3.self_attn.q_proj.biases":{"data_offsets":[2092978304,2094944384],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.3.self_attn.q_proj.scales":{"data_offsets":[2019791680,2021757760],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.3.self_attn.q_proj.weight":{"data_offsets":[1956522304,1987979584],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.3.self_attn.v_proj.biases":{"data_offsets":[2125545696,2125709536],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.3.self_attn.v_proj.scales":{"data_offsets":[1324466080,1324629920],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.3.self_attn.v_proj.weight":{"data_offsets":[2097808000,2100429440],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.4.input_layernorm.weight":{"data_offsets":[1631648864,1631659104],"dtype":"BF16","shape":[5120]},"model.language_model.layers.4.linear_attn.A_log":{"data_offsets":[1272535104,1272535200],"dtype":"BF16","shape":[48]},"model.language_model.layers.4.linear_attn.conv1d.weight":{"data_offsets":[2095069568,2095151488],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.4.linear_attn.dt_bias":{"data_offsets":[1846801376,1846801472],"dtype":"BF16","shape":[48]},"model.language_model.layers.4.linear_attn.in_proj_a.biases":{"data_offsets":[1106116928,1106124608],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.4.linear_attn.in_proj_a.scales":{"data_offsets":[2053084992,2053092672],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.4.linear_attn.in_proj_a.weight":{"data_offsets":[879462080,879584960],"dtype":"U32","shape":[48,640]},"model.language_model.layers.4.linear_attn.in_proj_b.biases":{"data_offsets":[931437152,931444832],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.4.linear_attn.in_proj_b.scales":{"data_offsets":[2053092672,2053100352],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.4.linear_attn.in_proj_b.weight":{"data_offsets":[1593797728,1593920608],"dtype":"U32","shape":[48,640]},"model.language_model.layers.8.input_layernorm.weight":{"data_offsets":[152803872,152814112],"dtype":"BF16","shape":[5120]},"model.language_model.layers.8.linear_attn.A_log":{"data_offsets":[152803776,152803872],"dtype":"BF16","shape":[48]},"model.language_model.layers.8.linear_attn.conv1d.weight":{"data_offsets":[152721856,152803776],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.8.linear_attn.dt_bias":{"data_offsets":[2125545600,2125545696],"dtype":"BF16","shape":[48]},"model.language_model.layers.8.linear_attn.in_proj_a.biases":{"data_offsets":[190205472,190213152],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.8.linear_attn.in_proj_a.scales":{"data_offsets":[152714176,152721856],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.8.linear_attn.in_proj_a.weight":{"data_offsets":[152591296,152714176],"dtype":"U32","shape":[48,640]},"model.language_model.layers.8.linear_attn.in_proj_b.biases":{"data_offsets":[152460736,152468416],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.8.linear_attn.in_proj_b.scales":{"data_offsets":[897486432,897494112],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.8.linear_attn.in_proj_b.weight":{"data_offsets":[152468416,152591296],"dtype":"U32","shape":[48,640]},"model.language_model.layers.8.linear_attn.in_proj_qkv.biases":{"data_offsets":[754838976,756477376],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.8.linear_attn.in_proj_qkv.scales":{"data_offsets":[150822336,152460736],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.8.linear_attn.in_proj_qkv.weight":{"data_offsets":[1196227648,1215888448],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.8.linear_attn.in_proj_z.biases":{"data_offsets":[148856256,149839296],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.8.linear_attn.in_proj_z.scales":{"data_offsets":[149839296,150822336],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.8.linear_attn.in_proj_z.weight":{"data_offsets":[1381243712,1393040192],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.8.linear_attn.norm.weight":{"data_offsets":[1083825216,1083825472],"dtype":"BF16","shape":[128]},"model.language_model.layers.8.linear_attn.out_proj.biases":{"data_offsets":[1746654944,1747637984],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.8.linear_attn.out_proj.scales":{"data_offsets":[147873216,148856256],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.8.linear_attn.out_proj.weight":{"data_offsets":[1856752704,1868549184],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.8.mlp.down_proj.scales":{"data_offsets":[147838400,147873216],"dtype":"F16","shape":[17408]},"model.language_model.layers.8.mlp.down_proj.weight":{"data_offsets":[1810709216,1844132576],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.8.mlp.gate_proj.scales":{"data_offsets":[1856717888,1856752704],"dtype":"F16","shape":[17408]},"model.language_model.layers.8.mlp.gate_proj.weight":{"data_offsets":[1692662688,1726086048],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.8.mlp.up_proj.scales":{"data_offsets":[908127072,908161888],"dtype":"F16","shape":[17408]},"model.language_model.layers.8.mlp.up_proj.weight":{"data_offsets":[836110784,869534144],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.8.post_attention_layernorm.weight":{"data_offsets":[147828160,147838400],"dtype":"BF16","shape":[5120]},"model.language_model.layers.9.input_layernorm.weight":{"data_offsets":[1036941824,1036952064],"dtype":"BF16","shape":[5120]},"model.language_model.layers.9.linear_attn.A_log":{"data_offsets":[1356859616,1356859712],"dtype":"BF16","shape":[48]},"model.language_model.layers.9.linear_attn.conv1d.weight":{"data_offsets":[802393536,802475456],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.9.linear_attn.dt_bias":{"data_offsets":[539354880,539354976],"dtype":"BF16","shape":[48]},"model.language_model.layers.9.linear_attn.in_proj_a.biases":{"data_offsets":[931427168,931434848],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.9.linear_attn.in_proj_a.scales":{"data_offsets":[147820480,147828160],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.9.linear_attn.in_proj_a.weight":{"data_offsets":[2029735328,2029858208],"dtype":"U32","shape":[48,640]},"model.language_model.layers.9.linear_attn.in_proj_b.biases":{"data_offsets":[147689920,147697600],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.9.linear_attn.in_proj_b.scales":{"data_offsets":[1166500448,1166508128],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.9.linear_attn.in_proj_b.weight":{"data_offsets":[147697600,147820480],"dtype":"U32","shape":[48,640]},"model.language_model.layers.9.linear_attn.in_proj_qkv.biases":{"data_offsets":[2123907200,2125545600],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.9.linear_attn.in_proj_qkv.scales":{"data_offsets":[126390720,128029120],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.9.linear_attn.in_proj_qkv.weight":{"data_offsets":[128029120,147689920],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.9.linear_attn.in_proj_z.biases":{"data_offsets":[113611104,114594144],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.9.linear_attn.in_proj_z.scales":{"data_offsets":[1165498560,1166481600],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.9.linear_attn.in_proj_z.weight":{"data_offsets":[114594240,126390720],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.9.linear_attn.norm.weight":{"data_offsets":[1461700576,1461700832],"dtype":"BF16","shape":[128]},"model.language_model.layers.9.linear_attn.out_proj.biases":{"data_offsets":[99848544,100831584],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.9.linear_attn.out_proj.scales":{"data_offsets":[100831584,101814624],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.9.linear_attn.out_proj.weight":{"data_offsets":[101814624,113611104],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.9.mlp.down_proj.scales":{"data_offsets":[388569472,388604288],"dtype":"F16","shape":[17408]},"model.language_model.layers.9.mlp.down_proj.weight":{"data_offsets":[1003516160,1036939520],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.9.mlp.gate_proj.scales":{"data_offsets":[99813728,99848544],"dtype":"F16","shape":[17408]},"model.language_model.layers.9.mlp.gate_proj.weight":{"data_offsets":[673427296,706850656],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.9.mlp.up_proj.scales":{"data_offsets":[66355552,66390368],"dtype":"F16","shape":[17408]},"model.language_model.layers.9.mlp.up_proj.weight":{"data_offsets":[66390368,99813728],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.9.post_attention_layernorm.weight":{"data_offsets":[66345312,66355552],"dtype":"BF16","shape":[5120]},"model.visual.blocks.0.attn.proj.bias":{"data_offsets":[1844132576,1844134880],"dtype":"BF16","shape":[1152]},"model.visual.blocks.0.attn.proj.weight":{"data_offsets":[2082352864,2085007072],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.0.attn.qkv.bias":{"data_offsets":[2053075776,2053082688],"dtype":"BF16","shape":[3456]},"model.visual.blocks.0.attn.qkv.weight":{"data_offsets":[1544380352,1552342976],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.0.mlp.linear_fc1.bias":{"data_offsets":[1490328288,1490336896],"dtype":"BF16","shape":[4304]},"model.visual.blocks.0.mlp.linear_fc1.weight":{"data_offsets":[1552468160,1562384576],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.0.mlp.linear_fc2.bias":{"data_offsets":[1534418048,1534420352],"dtype":"BF16","shape":[1152]},"model.visual.blocks.0.mlp.linear_fc2.weight":{"data_offsets":[1946605888,1956522304],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.0.norm1.bias":{"data_offsets":[2032512416,2032514720],"dtype":"BF16","shape":[1152]},"model.visual.blocks.0.norm1.weight":{"data_offsets":[539354976,539357280],"dtype":"BF16","shape":[1152]},"model.visual.blocks.0.norm2.bias":{"data_offsets":[2095067264,2095069568],"dtype":"BF16","shape":[1152]},"model.visual.blocks.0.norm2.weight":{"data_offsets":[2042431136,2042433440],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.attn.proj.bias":{"data_offsets":[2125711840,2125714144],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.attn.proj.weight":{"data_offsets":[2042435744,2045089952],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.1.attn.qkv.bias":{"data_offsets":[1928530592,1928537504],"dtype":"BF16","shape":[3456]},"model.visual.blocks.1.attn.qkv.weight":{"data_offsets":[1995946816,2003909440],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.1.mlp.linear_fc1.bias":{"data_offsets":[1682735360,1682743968],"dtype":"BF16","shape":[4304]},"model.visual.blocks.1.mlp.linear_fc1.weight":{"data_offsets":[1593925216,1603841632],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.1.mlp.linear_fc2.bias":{"data_offsets":[1534437568,1534439872],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.mlp.linear_fc2.weight":{"data_offsets":[1682746272,1692662688],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.1.norm1.bias":{"data_offsets":[1603844192,1603846496],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.norm1.weight":{"data_offsets":[1412748864,1412751168],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.norm2.bias":{"data_offsets":[2053057184,2053059488],"dtype":"BF16","shape":[1152]},"model.visual.blocks.1.norm2.weight":{"data_offsets":[2053082688,2053084992],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.attn.proj.bias":{"data_offsets":[1066708224,1066710528],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.attn.proj.weight":{"data_offsets":[2005547840,2008202048],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.10.attn.qkv.bias":{"data_offsets":[1490336896,1490343808],"dtype":"BF16","shape":[3456]},"model.visual.blocks.10.attn.qkv.weight":{"data_offsets":[900157536,908120160],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.10.mlp.linear_fc1.bias":{"data_offsets":[1746644032,1746652640],"dtype":"BF16","shape":[4304]},"model.visual.blocks.10.mlp.linear_fc1.weight":{"data_offsets":[2032514720,2042431136],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.10.mlp.linear_fc2.bias":{"data_offsets":[931434848,931437152],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.mlp.linear_fc2.weight":{"data_offsets":[1225816384,1235732800],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.10.norm1.bias":{"data_offsets":[1938466208,1938468512],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.norm1.weight":{"data_offsets":[941371488,941373792],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.norm2.bias":{"data_offsets":[1083814304,1083816608],"dtype":"BF16","shape":[1152]},"model.visual.blocks.10.norm2.weight":{"data_offsets":[959276640,959278944],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.attn.proj.bias":{"data_offsets":[1928525984,1928528288],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.attn.proj.weight":{"data_offsets":[489313280,491967488],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.11.attn.qkv.bias":{"data_offsets":[1588241760,1588248672],"dtype":"BF16","shape":[3456]},"model.visual.blocks.11.attn.qkv.weight":{"data_offsets":[1264537664,1272500288],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.11.mlp.linear_fc1.bias":{"data_offsets":[1422751808,1422760416],"dtype":"BF16","shape":[4304]},"model.visual.blocks.11.mlp.linear_fc1.weight":{"data_offsets":[1846801472,1856717888],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.11.mlp.linear_fc2.bias":{"data_offsets":[1810706912,1810709216],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.mlp.linear_fc2.weight":{"data_offsets":[1781928416,1791844832],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.11.norm1.bias":{"data_offsets":[517035008,517037312],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.norm1.weight":{"data_offsets":[1003506944,1003509248],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.norm2.bias":{"data_offsets":[1175462400,1175464704],"dtype":"BF16","shape":[1152]},"model.visual.blocks.11.norm2.weight":{"data_offsets":[1746652640,1746654944],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.attn.proj.bias":{"data_offsets":[756479680,756481984],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.attn.proj.weight":{"data_offsets":[1356859712,1359513920],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.12.attn.qkv.bias":{"data_offsets":[1425424864,1425431776],"dtype":"BF16","shape":[3456]},"model.visual.blocks.12.attn.qkv.weight":{"data_offsets":[1738681408,1746644032],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.12.mlp.linear_fc1.bias":{"data_offsets":[1938470816,1938479424],"dtype":"BF16","shape":[4304]},"model.visual.blocks.12.mlp.linear_fc1.weight":{"data_offsets":[789851072,799767488],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.12.mlp.linear_fc2.bias":{"data_offsets":[1490343808,1490346112],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.mlp.linear_fc2.weight":{"data_offsets":[1106161728,1116078144],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.12.norm1.bias":{"data_offsets":[1738679104,1738681408],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.norm1.weight":{"data_offsets":[1728751168,1728753472],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.norm2.bias":{"data_offsets":[1003511552,1003513856],"dtype":"BF16","shape":[1152]},"model.visual.blocks.12.norm2.weight":{"data_offsets":[1593760608,1593762912],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.attn.proj.bias":{"data_offsets":[1188251808,1188254112],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.attn.proj.weight":{"data_offsets":[1422770656,1425424864],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.13.attn.qkv.bias":{"data_offsets":[951290208,951297120],"dtype":"BF16","shape":[3456]},"model.visual.blocks.13.attn.qkv.weight":{"data_offsets":[1603846496,1611809120],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.13.mlp.linear_fc1.bias":{"data_offsets":[2053059488,2053068096],"dtype":"BF16","shape":[4304]},"model.visual.blocks.13.mlp.linear_fc1.weight":{"data_offsets":[1662902528,1672818944],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.13.mlp.linear_fc2.bias":{"data_offsets":[1639624032,1639626336],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.mlp.linear_fc2.weight":{"data_offsets":[1621725536,1631641952],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.13.norm1.bias":{"data_offsets":[951297120,951299424],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.norm1.weight":{"data_offsets":[1603841632,1603843936],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.norm2.bias":{"data_offsets":[1593922912,1593925216],"dtype":"BF16","shape":[1152]},"model.visual.blocks.13.norm2.weight":{"data_offsets":[1264535360,1264537664],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.attn.proj.bias":{"data_offsets":[1449125344,1449127648],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.attn.proj.weight":{"data_offsets":[2077034208,2079688416],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.14.attn.qkv.bias":{"data_offsets":[1588248672,1588255584],"dtype":"BF16","shape":[3456]},"model.visual.blocks.14.attn.qkv.weight":{"data_offsets":[1570354112,1578316736],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.14.mlp.linear_fc1.bias":{"data_offsets":[1174470752,1174479360],"dtype":"BF16","shape":[4304]},"model.visual.blocks.14.mlp.linear_fc1.weight":{"data_offsets":[1046875392,1056791808],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.14.mlp.linear_fc2.bias":{"data_offsets":[1639621728,1639624032],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.mlp.linear_fc2.weight":{"data_offsets":[2100429440,2110345856],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.14.norm1.bias":{"data_offsets":[1938463904,1938466208],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.norm1.weight":{"data_offsets":[1129408992,1129411296],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.norm2.bias":{"data_offsets":[1562384576,1562386880],"dtype":"BF16","shape":[1152]},"model.visual.blocks.14.norm2.weight":{"data_offsets":[1534451392,1534453696],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.attn.proj.bias":{"data_offsets":[1562389184,1562391488],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.attn.proj.weight":{"data_offsets":[2029858208,2032512416],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.15.attn.qkv.bias":{"data_offsets":[1534439872,1534446784],"dtype":"BF16","shape":[3456]},"model.visual.blocks.15.attn.qkv.weight":{"data_offsets":[1872188736,1880151360],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.15.mlp.linear_fc1.bias":{"data_offsets":[1324629920,1324638528],"dtype":"BF16","shape":[4304]},"model.visual.blocks.15.mlp.linear_fc1.weight":{"data_offsets":[1254618944,1264535360],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.15.mlp.linear_fc2.bias":{"data_offsets":[1502956160,1502958464],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.mlp.linear_fc2.weight":{"data_offsets":[1493037440,1502953856],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.15.norm1.bias":{"data_offsets":[1738676800,1738679104],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.norm1.weight":{"data_offsets":[1083812000,1083814304],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.norm2.bias":{"data_offsets":[1178324480,1178326784],"dtype":"BF16","shape":[1152]},"model.visual.blocks.15.norm2.weight":{"data_offsets":[1760208608,1760210912],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.attn.proj.bias":{"data_offsets":[756494528,756496832],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.attn.proj.weight":{"data_offsets":[2079688416,2082342624],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.16.attn.qkv.bias":{"data_offsets":[1461707744,1461714656],"dtype":"BF16","shape":[3456]},"model.visual.blocks.16.attn.qkv.weight":{"data_offsets":[1066882976,1074845600],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.16.mlp.linear_fc1.bias":{"data_offsets":[887556800,887565408],"dtype":"BF16","shape":[4304]},"model.visual.blocks.16.mlp.linear_fc1.weight":{"data_offsets":[2008202048,2018118464],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.16.mlp.linear_fc2.bias":{"data_offsets":[1461700832,1461703136],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.mlp.linear_fc2.weight":{"data_offsets":[1451784160,1461700576],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.16.norm1.bias":{"data_offsets":[1661908576,1661910880],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.norm1.weight":{"data_offsets":[1451781856,1451784160],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.norm2.bias":{"data_offsets":[1760210912,1760213216],"dtype":"BF16","shape":[1152]},"model.visual.blocks.16.norm2.weight":{"data_offsets":[2042433440,2042435744],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.attn.proj.bias":{"data_offsets":[1995944512,1995946816],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.attn.proj.weight":{"data_offsets":[1726088352,1728742560],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.17.attn.qkv.bias":{"data_offsets":[1243695424,1243702336],"dtype":"BF16","shape":[3456]},"model.visual.blocks.17.attn.qkv.weight":{"data_offsets":[1425434080,1433396704],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.17.mlp.linear_fc1.bias":{"data_offsets":[1728742560,1728751168],"dtype":"BF16","shape":[4304]},"model.visual.blocks.17.mlp.linear_fc1.weight":{"data_offsets":[1272535200,1282451616],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.17.mlp.linear_fc2.bias":{"data_offsets":[1412790592,1412792896],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.mlp.linear_fc2.weight":{"data_offsets":[1282451616,1292368032],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.17.norm1.bias":{"data_offsets":[1412746560,1412748864],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.norm1.weight":{"data_offsets":[1412735040,1412737344],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.norm2.bias":{"data_offsets":[1412714816,1412717120],"dtype":"BF16","shape":[1152]},"model.visual.blocks.17.norm2.weight":{"data_offsets":[1726086048,1726088352],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.attn.proj.bias":{"data_offsets":[1412712512,1412714816],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.attn.proj.weight":{"data_offsets":[1116078144,1118732352],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.18.attn.qkv.bias":{"data_offsets":[1393042496,1393049408],"dtype":"BF16","shape":[3456]},"model.visual.blocks.18.attn.qkv.weight":{"data_offsets":[1631659104,1639621728],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.18.mlp.linear_fc1.bias":{"data_offsets":[1588233152,1588241760],"dtype":"BF16","shape":[4304]},"model.visual.blocks.18.mlp.linear_fc1.weight":{"data_offsets":[1534463936,1544380352],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.18.mlp.linear_fc2.bias":{"data_offsets":[1381241408,1381243712],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.mlp.linear_fc2.weight":{"data_offsets":[1359528512,1369444928],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.18.norm1.bias":{"data_offsets":[1412788288,1412790592],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.norm1.weight":{"data_offsets":[1036954368,1036956672],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.norm2.bias":{"data_offsets":[1359521600,1359523904],"dtype":"BF16","shape":[1152]},"model.visual.blocks.18.norm2.weight":{"data_offsets":[712278208,712280512],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.attn.proj.bias":{"data_offsets":[1461705440,1461707744],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.attn.proj.weight":{"data_offsets":[1449127648,1451781856],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.19.attn.qkv.bias":{"data_offsets":[1118732352,1118739264],"dtype":"BF16","shape":[3456]},"model.visual.blocks.19.attn.qkv.weight":{"data_offsets":[2085015680,2092978304],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.19.mlp.linear_fc1.bias":{"data_offsets":[1166481600,1166490208],"dtype":"BF16","shape":[4304]},"model.visual.blocks.19.mlp.linear_fc1.weight":{"data_offsets":[1140337792,1150254208],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.19.mlp.linear_fc2.bias":{"data_offsets":[1467058400,1467060704],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.mlp.linear_fc2.weight":{"data_offsets":[1346943200,1356859616],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.19.norm1.bias":{"data_offsets":[1393040192,1393042496],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.norm1.weight":{"data_offsets":[1346940896,1346943200],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.norm2.bias":{"data_offsets":[2053102656,2053104960],"dtype":"BF16","shape":[1152]},"model.visual.blocks.19.norm2.weight":{"data_offsets":[1324645440,1324647744],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.attn.proj.bias":{"data_offsets":[1995942208,1995944512],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.attn.proj.weight":{"data_offsets":[1126752480,1129406688],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.2.attn.qkv.bias":{"data_offsets":[1324638528,1324645440],"dtype":"BF16","shape":[3456]},"model.visual.blocks.2.attn.qkv.weight":{"data_offsets":[1314865056,1322827680],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.2.mlp.linear_fc1.bias":{"data_offsets":[1188254112,1188262720],"dtype":"BF16","shape":[4304]},"model.visual.blocks.2.mlp.linear_fc1.weight":{"data_offsets":[1304940960,1314857376],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.2.mlp.linear_fc2.bias":{"data_offsets":[2045092256,2045094560],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.mlp.linear_fc2.weight":{"data_offsets":[1295024544,1304940960],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.2.norm1.bias":{"data_offsets":[2021770304,2021772608],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.norm1.weight":{"data_offsets":[1534415744,1534418048],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.norm2.bias":{"data_offsets":[653510752,653513056],"dtype":"BF16","shape":[1152]},"model.visual.blocks.2.norm2.weight":{"data_offsets":[1490346112,1490348416],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.attn.proj.bias":{"data_offsets":[1938453920,1938456224],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.attn.proj.weight":{"data_offsets":[1292368032,1295022240],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.20.attn.qkv.bias":{"data_offsets":[1253618752,1253625664],"dtype":"BF16","shape":[3456]},"model.visual.blocks.20.attn.qkv.weight":{"data_offsets":[1235732800,1243695424],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.20.mlp.linear_fc1.bias":{"data_offsets":[1534420352,1534428960],"dtype":"BF16","shape":[4304]},"model.visual.blocks.20.mlp.linear_fc1.weight":{"data_offsets":[1611809120,1621725536],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.20.mlp.linear_fc2.bias":{"data_offsets":[1502953856,1502956160],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.mlp.linear_fc2.weight":{"data_offsets":[1215899968,1225816384],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.20.norm1.bias":{"data_offsets":[1425431776,1425434080],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.norm1.weight":{"data_offsets":[1938468512,1938470816],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.norm2.bias":{"data_offsets":[1928523680,1928525984],"dtype":"BF16","shape":[1152]},"model.visual.blocks.20.norm2.weight":{"data_offsets":[1215897664,1215899968],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.attn.proj.bias":{"data_offsets":[818213312,818215616],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.attn.proj.weight":{"data_offsets":[1869534528,1872188736],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.21.attn.qkv.bias":{"data_offsets":[1215888448,1215895360],"dtype":"BF16","shape":[3456]},"model.visual.blocks.21.attn.qkv.weight":{"data_offsets":[1188262720,1196225344],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.21.mlp.linear_fc1.bias":{"data_offsets":[1188243200,1188251808],"dtype":"BF16","shape":[4304]},"model.visual.blocks.21.mlp.linear_fc1.weight":{"data_offsets":[1178326784,1188243200],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.21.mlp.linear_fc2.bias":{"data_offsets":[2125709536,2125711840],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.mlp.linear_fc2.weight":{"data_offsets":[1760213216,1770129632],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.21.norm1.bias":{"data_offsets":[1196225344,1196227648],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.norm1.weight":{"data_offsets":[1869532224,1869534528],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.norm2.bias":{"data_offsets":[1178121216,1178123520],"dtype":"BF16","shape":[1152]},"model.visual.blocks.21.norm2.weight":{"data_offsets":[1880315200,1880317504],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.attn.proj.bias":{"data_offsets":[1175464704,1175467008],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.attn.proj.weight":{"data_offsets":[1844134880,1846789088],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.22.attn.qkv.bias":{"data_offsets":[1412739648,1412746560],"dtype":"BF16","shape":[3456]},"model.visual.blocks.22.attn.qkv.weight":{"data_offsets":[1166508128,1174470752],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.22.mlp.linear_fc1.bias":{"data_offsets":[1165489952,1165498560],"dtype":"BF16","shape":[4304]},"model.visual.blocks.22.mlp.linear_fc1.weight":{"data_offsets":[1155564928,1165481344],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.22.mlp.linear_fc2.bias":{"data_offsets":[1412710208,1412712512],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.mlp.linear_fc2.weight":{"data_offsets":[1799807456,1809723872],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.22.norm1.bias":{"data_offsets":[1489342944,1489345248],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.norm1.weight":{"data_offsets":[2045089952,2045092256],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.norm2.bias":{"data_offsets":[1928486464,1928488768],"dtype":"BF16","shape":[1152]},"model.visual.blocks.22.norm2.weight":{"data_offsets":[1155562624,1155564928],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.attn.proj.bias":{"data_offsets":[1552342976,1552345280],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.attn.proj.weight":{"data_offsets":[1150254208,1152908416],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.23.attn.qkv.bias":{"data_offsets":[1140322272,1140329184],"dtype":"BF16","shape":[3456]},"model.visual.blocks.23.attn.qkv.weight":{"data_offsets":[1791844832,1799807456],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.23.mlp.linear_fc1.bias":{"data_offsets":[2085007072,2085015680],"dtype":"BF16","shape":[4304]},"model.visual.blocks.23.mlp.linear_fc1.weight":{"data_offsets":[1750292192,1760208608],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.23.mlp.linear_fc2.bias":{"data_offsets":[2021768000,2021770304],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.mlp.linear_fc2.weight":{"data_offsets":[1129415904,1139332320],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.23.norm1.bias":{"data_offsets":[1118739264,1118741568],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.norm1.weight":{"data_offsets":[1129411296,1129413600],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.norm2.bias":{"data_offsets":[1129406688,1129408992],"dtype":"BF16","shape":[1152]},"model.visual.blocks.23.norm2.weight":{"data_offsets":[1534446784,1534449088],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.attn.proj.bias":{"data_offsets":[1126715104,1126717408],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.attn.proj.weight":{"data_offsets":[2095151488,2097805696],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.24.attn.qkv.bias":{"data_offsets":[1082808224,1082815136],"dtype":"BF16","shape":[3456]},"model.visual.blocks.24.attn.qkv.weight":{"data_offsets":[1118752480,1126715104],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.24.mlp.linear_fc1.bias":{"data_offsets":[1118743872,1118752480],"dtype":"BF16","shape":[4304]},"model.visual.blocks.24.mlp.linear_fc1.weight":{"data_offsets":[641955936,651872352],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.24.mlp.linear_fc2.bias":{"data_offsets":[756481984,756484288],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.mlp.linear_fc2.weight":{"data_offsets":[1243702336,1253618752],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.24.norm1.bias":{"data_offsets":[1106124608,1106126912],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.norm1.weight":{"data_offsets":[1461703136,1461705440],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.norm2.bias":{"data_offsets":[1106112320,1106114624],"dtype":"BF16","shape":[1152]},"model.visual.blocks.24.norm2.weight":{"data_offsets":[1106110016,1106112320],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.attn.proj.bias":{"data_offsets":[1106107712,1106110016],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.attn.proj.weight":{"data_offsets":[1490383232,1493037440],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.25.attn.qkv.bias":{"data_offsets":[1631641952,1631648864],"dtype":"BF16","shape":[3456]},"model.visual.blocks.25.attn.qkv.weight":{"data_offsets":[1987979584,1995942208],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.25.mlp.linear_fc1.bias":{"data_offsets":[1083816608,1083825216],"dtype":"BF16","shape":[4304]},"model.visual.blocks.25.mlp.linear_fc1.weight":{"data_offsets":[959278944,969195360],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.25.mlp.linear_fc2.bias":{"data_offsets":[1083807392,1083809696],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.mlp.linear_fc2.weight":{"data_offsets":[2113007744,2122924160],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.25.norm1.bias":{"data_offsets":[2097805696,2097808000],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.norm1.weight":{"data_offsets":[1083809696,1083812000],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.norm2.bias":{"data_offsets":[1846799072,1846801376],"dtype":"BF16","shape":[1152]},"model.visual.blocks.25.norm2.weight":{"data_offsets":[1215895360,1215897664],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.attn.proj.bias":{"data_offsets":[1083805088,1083807392],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.attn.proj.weight":{"data_offsets":[1175467008,1178121216],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.26.attn.qkv.bias":{"data_offsets":[1082815136,1082822048],"dtype":"BF16","shape":[3456]},"model.visual.blocks.26.attn.qkv.weight":{"data_offsets":[1074845600,1082808224],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.26.mlp.linear_fc1.bias":{"data_offsets":[1066874368,1066882976],"dtype":"BF16","shape":[4304]},"model.visual.blocks.26.mlp.linear_fc1.weight":{"data_offsets":[1056791808,1066708224],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.26.mlp.linear_fc2.bias":{"data_offsets":[1046873088,1046875392],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.mlp.linear_fc2.weight":{"data_offsets":[1036956672,1046873088],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.26.norm1.bias":{"data_offsets":[1036952064,1036954368],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.norm1.weight":{"data_offsets":[1036939520,1036941824],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.norm2.bias":{"data_offsets":[1003513856,1003516160],"dtype":"BF16","shape":[1152]},"model.visual.blocks.26.norm2.weight":{"data_offsets":[1593920608,1593922912],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.attn.proj.bias":{"data_offsets":[1003509248,1003511552],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.attn.proj.weight":{"data_offsets":[1152908416,1155562624],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.3.attn.qkv.bias":{"data_offsets":[1140315360,1140322272],"dtype":"BF16","shape":[3456]},"model.visual.blocks.3.attn.qkv.weight":{"data_offsets":[2045094560,2053057184],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.3.mlp.linear_fc1.bias":{"data_offsets":[993571680,993580288],"dtype":"BF16","shape":[4304]},"model.visual.blocks.3.mlp.linear_fc1.weight":{"data_offsets":[1412800576,1422716992],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.3.mlp.linear_fc2.bias":{"data_offsets":[1412737344,1412739648],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.mlp.linear_fc2.weight":{"data_offsets":[983655264,993571680],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.3.norm1.bias":{"data_offsets":[971856480,971858784],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.norm1.weight":{"data_offsets":[971854176,971856480],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.norm2.bias":{"data_offsets":[1412785984,1412788288],"dtype":"BF16","shape":[1152]},"model.visual.blocks.3.norm2.weight":{"data_offsets":[1295022240,1295024544],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.attn.proj.bias":{"data_offsets":[971849568,971851872],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.attn.proj.weight":{"data_offsets":[969195360,971849568],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.4.attn.qkv.bias":{"data_offsets":[959262048,959268960],"dtype":"BF16","shape":[3456]},"model.visual.blocks.4.attn.qkv.weight":{"data_offsets":[951299424,959262048],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.4.mlp.linear_fc1.bias":{"data_offsets":[1534428960,1534437568],"dtype":"BF16","shape":[4304]},"model.visual.blocks.4.mlp.linear_fc1.weight":{"data_offsets":[941373792,951290208],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.4.mlp.linear_fc2.bias":{"data_offsets":[1129413600,1129415904],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.mlp.linear_fc2.weight":{"data_offsets":[931444832,941361248],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.4.norm1.bias":{"data_offsets":[908124768,908127072],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.norm1.weight":{"data_offsets":[908122464,908124768],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.norm2.bias":{"data_offsets":[1682743968,1682746272],"dtype":"BF16","shape":[1152]},"model.visual.blocks.4.norm2.weight":{"data_offsets":[908120160,908122464],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.attn.proj.bias":{"data_offsets":[900155232,900157536],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.attn.proj.weight":{"data_offsets":[897494112,900148320],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.5.attn.qkv.bias":{"data_offsets":[900148320,900155232],"dtype":"BF16","shape":[3456]},"model.visual.blocks.5.attn.qkv.weight":{"data_offsets":[1938643264,1946605888],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.5.mlp.linear_fc1.bias":{"data_offsets":[1165481344,1165489952],"dtype":"BF16","shape":[4304]},"model.visual.blocks.5.mlp.linear_fc1.weight":{"data_offsets":[887570016,897486432],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.5.mlp.linear_fc2.bias":{"data_offsets":[887567712,887570016],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.mlp.linear_fc2.weight":{"data_offsets":[1578316736,1588233152],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.5.norm1.bias":{"data_offsets":[1106114624,1106116928],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.norm1.weight":{"data_offsets":[1359526208,1359528512],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.norm2.bias":{"data_offsets":[887565408,887567712],"dtype":"BF16","shape":[1152]},"model.visual.blocks.5.norm2.weight":{"data_offsets":[1928528288,1928530592],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.attn.proj.bias":{"data_offsets":[887554496,887556800],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.attn.proj.weight":{"data_offsets":[1747637984,1750292192],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.6.attn.qkv.bias":{"data_offsets":[887547584,887554496],"dtype":"BF16","shape":[3456]},"model.visual.blocks.6.attn.qkv.weight":{"data_offsets":[879584960,887547584],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.6.mlp.linear_fc1.bias":{"data_offsets":[1346932288,1346940896],"dtype":"BF16","shape":[4304]},"model.visual.blocks.6.mlp.linear_fc1.weight":{"data_offsets":[993580288,1003496704],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.6.mlp.linear_fc2.bias":{"data_offsets":[1178287360,1178289664],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.mlp.linear_fc2.weight":{"data_offsets":[869545664,879462080],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.6.norm1.bias":{"data_offsets":[1359523904,1359526208],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.norm1.weight":{"data_offsets":[1534449088,1534451392],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.norm2.bias":{"data_offsets":[971851872,971854176],"dtype":"BF16","shape":[1152]},"model.visual.blocks.6.norm2.weight":{"data_offsets":[869543360,869545664],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.attn.proj.bias":{"data_offsets":[869541056,869543360],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.attn.proj.weight":{"data_offsets":[2110345856,2113000064],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.7.attn.qkv.bias":{"data_offsets":[1738669888,1738676800],"dtype":"BF16","shape":[3456]},"model.visual.blocks.7.attn.qkv.weight":{"data_offsets":[1562391488,1570354112],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.7.mlp.linear_fc1.bias":{"data_offsets":[1662893920,1662902528],"dtype":"BF16","shape":[4304]},"model.visual.blocks.7.mlp.linear_fc1.weight":{"data_offsets":[1672818944,1682735360],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.7.mlp.linear_fc2.bias":{"data_offsets":[869538752,869541056],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.mlp.linear_fc2.weight":{"data_offsets":[1928537504,1938453920],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.7.norm1.bias":{"data_offsets":[869536448,869538752],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.norm1.weight":{"data_offsets":[869534144,869536448],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.norm2.bias":{"data_offsets":[836108480,836110784],"dtype":"BF16","shape":[1152]},"model.visual.blocks.7.norm2.weight":{"data_offsets":[1846789088,1846791392],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.attn.proj.bias":{"data_offsets":[836106176,836108480],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.attn.proj.weight":{"data_offsets":[1461714656,1464368864],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.8.attn.qkv.bias":{"data_offsets":[836099264,836106176],"dtype":"BF16","shape":[3456]},"model.visual.blocks.8.attn.qkv.weight":{"data_offsets":[828136640,836099264],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.8.mlp.linear_fc1.bias":{"data_offsets":[1140329184,1140337792],"dtype":"BF16","shape":[4304]},"model.visual.blocks.8.mlp.linear_fc1.weight":{"data_offsets":[1728753472,1738669888],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.8.mlp.linear_fc2.bias":{"data_offsets":[818217920,818220224],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.mlp.linear_fc2.weight":{"data_offsets":[818220224,828136640],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.8.norm1.bias":{"data_offsets":[818204096,818206400],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.norm1.weight":{"data_offsets":[818215616,818217920],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.norm2.bias":{"data_offsets":[800752832,800755136],"dtype":"BF16","shape":[1152]},"model.visual.blocks.8.norm2.weight":{"data_offsets":[799767488,799769792],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.attn.proj.bias":{"data_offsets":[1781926112,1781928416],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.attn.proj.weight":{"data_offsets":[1464404192,1467058400],"dtype":"BF16","shape":[1152,1152]},"model.visual.blocks.9.attn.qkv.bias":{"data_offsets":[818206400,818213312],"dtype":"BF16","shape":[3456]},"model.visual.blocks.9.attn.qkv.weight":{"data_offsets":[2021772704,2029735328],"dtype":"BF16","shape":[3456,1152]},"model.visual.blocks.9.mlp.linear_fc1.bias":{"data_offsets":[2077025600,2077034208],"dtype":"BF16","shape":[4304]},"model.visual.blocks.9.mlp.linear_fc1.weight":{"data_offsets":[779934656,789851072],"dtype":"BF16","shape":[4304,1152]},"model.visual.blocks.9.mlp.linear_fc2.bias":{"data_offsets":[779850432,779852736],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.mlp.linear_fc2.weight":{"data_offsets":[758137536,768053952],"dtype":"BF16","shape":[1152,4304]},"model.visual.blocks.9.norm1.bias":{"data_offsets":[756496832,756499136],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.norm1.weight":{"data_offsets":[1324647744,1324650048],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.norm2.bias":{"data_offsets":[2053100352,2053102656],"dtype":"BF16","shape":[1152]},"model.visual.blocks.9.norm2.weight":{"data_offsets":[756477376,756479680],"dtype":"BF16","shape":[1152]},"model.visual.merger.linear_fc1.bias":{"data_offsets":[754747840,754757056],"dtype":"BF16","shape":[4608]},"model.visual.merger.linear_fc1.weight":{"data_offsets":[712280512,754747840],"dtype":"BF16","shape":[4608,4608]},"model.visual.merger.linear_fc2.bias":{"data_offsets":[2021757760,2021768000],"dtype":"BF16","shape":[5120]},"model.visual.merger.linear_fc2.weight":{"data_offsets":[1880317504,1927503424],"dtype":"BF16","shape":[5120,4608]},"model.visual.merger.norm.bias":{"data_offsets":[712275904,712278208],"dtype":"BF16","shape":[1152]},"model.visual.merger.norm.weight":{"data_offsets":[1118741568,1118743872],"dtype":"BF16","shape":[1152]},"model.visual.patch_embed.proj.bias":{"data_offsets":[1562386880,1562389184],"dtype":"BF16","shape":[1152]},"model.visual.patch_embed.proj.weight":{"data_offsets":[1590221664,1593760608],"dtype":"BF16","shape":[1152,3,2,16,16]},"model.visual.pos_embed.weight":{"data_offsets":[706967488,712275904],"dtype":"BF16","shape":[2304,1152]}}"#
data_chars header1Chars header1

/-- Verbatim JSON header of `model-00003-of-00006.safetensors` (bytes 8 … 49762). -/
def header2 : String := r#"{"__metadata__":{"format":"mlx"},"model.language_model.layers.16.mlp.up_proj.scales":{"data_offsets":[1989718336,1989753152],"dtype":"F16","shape":[17408]},"model.language_model.layers.16.mlp.up_proj.weight":{"data_offsets":[2067940160,2090222400],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.16.post_attention_layernorm.weight":{"data_offsets":[2143972160,2143982400],"dtype":"BF16","shape":[5120]},"model.language_model.layers.17.input_layernorm.weight":{"data_offsets":[1451392736,1451402976],"dtype":"BF16","shape":[5120]},"model.language_model.layers.17.linear_attn.A_log":{"data_offsets":[1721654432,1721654528],"dtype":"BF16","shape":[48]},"model.language_model.layers.17.linear_attn.conv1d.weight":{"data_offsets":[1166483840,1166565760],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.17.linear_attn.dt_bias":{"data_offsets":[1919711680,1919711776],"dtype":"BF16","shape":[48]},"model.language_model.layers.17.linear_attn.in_proj_a.biases":{"data_offsets":[964021440,964029120],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.17.linear_attn.in_proj_a.scales":{"data_offsets":[2056005440,2056013120],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.17.linear_attn.in_proj_a.weight":{"data_offsets":[1541233568,1541356448],"dtype":"U32","shape":[48,640]},"model.language_model.layers.17.linear_attn.in_proj_b.biases":{"data_offsets":[1838759360,1838767040],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.17.linear_attn.in_proj_b.scales":{"data_offsets":[1352424928,1352432608],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.17.linear_attn.in_proj_b.weight":{"data_offsets":[1956164416,1956287296],"dtype":"U32","shape":[48,640]},"model.language_model.layers.17.linear_attn.in_proj_qkv.biases":{"data_offsets":[1541356960,1542995360],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.17.linear_attn.in_proj_qkv.scales":{"data_offsets":[2024212800,2025851200],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.17.linear_attn.in_proj_qkv.weight":{"data_offsets":[1899067840,1918728640],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.17.linear_attn.in_proj_z.biases":{"data_offsets":[1804317792,1805300832],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.17.linear_attn.in_proj_z.scales":{"data_offsets":[1920893568,1921876608],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.17.linear_attn.in_proj_z.weight":{"data_offsets":[1921921664,1933718144],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.17.linear_attn.norm.weight":{"data_offsets":[1807266912,1807267168],"dtype":"BF16","shape":[128]},"model.language_model.layers.17.linear_attn.out_proj.biases":{"data_offsets":[1919711776,1920694816],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.17.linear_attn.out_proj.scales":{"data_offsets":[1838767040,1839750080],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.17.linear_attn.out_proj.weight":{"data_offsets":[1451402976,1463199456],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.17.mlp.down_proj.scales":{"data_offsets":[1542995360,1543030176],"dtype":"F16","shape":[17408]},"model.language_model.layers.17.mlp.down_proj.weight":{"data_offsets":[1933882080,1956164320],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.17.mlp.gate_proj.scales":{"data_offsets":[722730496,722765312],"dtype":"F16","shape":[17408]},"model.language_model.layers.17.mlp.gate_proj.weight":{"data_offsets":[2121679680,2143961920],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.17.mlp.up_proj.scales":{"data_offsets":[1766927200,1766962016],"dtype":"F16","shape":[17408]},"model.language_model.layers.17.mlp.up_proj.weight":{"data_offsets":[1429110240,1451392480],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.17.post_attention_layernorm.weight":{"data_offsets":[1755077888,1755088128],"dtype":"BF16","shape":[5120]},"model.language_model.layers.18.input_layernorm.weight":{"data_offsets":[1703054496,1703064736],"dtype":"BF16","shape":[5120]},"model.language_model.layers.18.linear_attn.A_log":{"data_offsets":[1755095808,1755095904],"dtype":"BF16","shape":[48]},"model.language_model.layers.18.linear_attn.conv1d.weight":{"data_offsets":[1705720992,1705802912],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.18.linear_attn.dt_bias":{"data_offsets":[1535990592,1535990688],"dtype":"BF16","shape":[48]},"model.language_model.layers.18.linear_attn.in_proj_a.biases":{"data_offsets":[1862032320,1862040000],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.18.linear_attn.in_proj_a.scales":{"data_offsets":[1570213792,1570221472],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.18.linear_attn.in_proj_a.weight":{"data_offsets":[940444768,940567648],"dtype":"U32","shape":[48,640]},"model.language_model.layers.18.linear_attn.in_proj_b.biases":{"data_offsets":[1185908096,1185915776],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.18.linear_attn.in_proj_b.scales":{"data_offsets":[1235117952,1235125632],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.18.linear_attn.in_proj_b.weight":{"data_offsets":[1705802912,1705925792],"dtype":"U32","shape":[48,640]},"model.language_model.layers.18.linear_attn.in_proj_qkv.biases":{"data_offsets":[1701381280,1703019680],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.18.linear_attn.in_proj_qkv.scales":{"data_offsets":[1703064736,1704703136],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.18.linear_attn.in_proj_qkv.weight":{"data_offsets":[1767945056,1787605856],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.18.linear_attn.in_proj_z.biases":{"data_offsets":[1508426976,1509410016],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.18.linear_attn.in_proj_z.scales":{"data_offsets":[1989787968,1990771008],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.18.linear_attn.in_proj_z.weight":{"data_offsets":[2109883200,2121679680],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.18.linear_attn.norm.weight":{"data_offsets":[1662309792,1662310048],"dtype":"BF16","shape":[128]},"model.language_model.layers.18.linear_attn.out_proj.biases":{"data_offsets":[1509410016,1510393056],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.18.linear_attn.out_proj.scales":{"data_offsets":[1684880544,1685863584],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.18.linear_attn.out_proj.weight":{"data_offsets":[1687829664,1699626144],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.18.mlp.down_proj.scales":{"data_offsets":[1920858752,1920893568],"dtype":"F16","shape":[17408]},"model.language_model.layers.18.mlp.down_proj.weight":{"data_offsets":[1662344864,1684627104],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.18.mlp.gate_proj.scales":{"data_offsets":[1704703136,1704737952],"dtype":"F16","shape":[17408]},"model.language_model.layers.18.mlp.gate_proj.weight":{"data_offsets":[1862040000,1895463360],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.18.mlp.up_proj.scales":{"data_offsets":[1838724544,1838759360],"dtype":"F16","shape":[17408]},"model.language_model.layers.18.mlp.up_proj.weight":{"data_offsets":[1628886432,1662309792],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.18.post_attention_layernorm.weight":{"data_offsets":[1544082848,1544093088],"dtype":"BF16","shape":[5120]},"model.language_model.layers.19.input_layernorm.weight":{"data_offsets":[1510679776,1510690016],"dtype":"BF16","shape":[5120]},"model.language_model.layers.19.mlp.down_proj.scales":{"data_offsets":[1544048032,1544082848],"dtype":"F16","shape":[17408]},"model.language_model.layers.19.mlp.down_proj.weight":{"data_offsets":[1990788928,2024212288],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.19.mlp.gate_proj.scales":{"data_offsets":[634121120,634155936],"dtype":"F16","shape":[17408]},"model.language_model.layers.19.mlp.gate_proj.weight":{"data_offsets":[1510690016,1532972256],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.19.mlp.up_proj.scales":{"data_offsets":[1570178976,1570213792],"dtype":"F16","shape":[17408]},"model.language_model.layers.19.mlp.up_proj.weight":{"data_offsets":[1605610912,1627893152],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.19.post_attention_layernorm.weight":{"data_offsets":[1628876192,1628886432],"dtype":"BF16","shape":[5120]},"model.language_model.layers.19.self_attn.k_norm.weight":{"data_offsets":[1547896224,1547896736],"dtype":"BF16","shape":[256]},"model.language_model.layers.19.self_attn.k_proj.biases":{"data_offsets":[1510515936,1510679776],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.19.self_attn.k_proj.scales":{"data_offsets":[1545076128,1545239968],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.19.self_attn.k_proj.weight":{"data_offsets":[1545239968,1547861408],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.19.self_attn.o_proj.biases":{"data_offsets":[1167548800,1168531840],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.19.self_attn.o_proj.scales":{"data_offsets":[1803334752,1804317792],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.19.self_attn.o_proj.weight":{"data_offsets":[1787605856,1803334496],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.19.self_attn.q_norm.weight":{"data_offsets":[1541356448,1541356960],"dtype":"BF16","shape":[256]},"model.language_model.layers.19.self_attn.q_proj.biases":{"data_offsets":[839087200,841053280],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.19.self_attn.q_proj.scales":{"data_offsets":[1685863584,1687829664],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.19.self_attn.q_proj.weight":{"data_offsets":[1807267264,1838724544],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.19.self_attn.v_proj.biases":{"data_offsets":[1933718240,1933882080],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.19.self_attn.v_proj.scales":{"data_offsets":[1920694912,1920858752],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.19.self_attn.v_proj.weight":{"data_offsets":[1535990688,1538612128],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.20.input_layernorm.weight":{"data_offsets":[1535980352,1535990592],"dtype":"BF16","shape":[5120]},"model.language_model.layers.20.linear_attn.A_log":{"data_offsets":[1920694816,1920694912],"dtype":"BF16","shape":[48]},"model.language_model.layers.20.linear_attn.conv1d.weight":{"data_offsets":[1533276896,1533358816],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.20.linear_attn.dt_bias":{"data_offsets":[1533358816,1533358912],"dtype":"BF16","shape":[48]},"model.language_model.layers.20.linear_attn.in_proj_a.biases":{"data_offsets":[1180328320,1180336000],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.20.linear_attn.in_proj_a.scales":{"data_offsets":[2040269120,2040276800],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.20.linear_attn.in_proj_a.weight":{"data_offsets":[1532979936,1533102816],"dtype":"U32","shape":[48,640]},"model.language_model.layers.20.linear_attn.in_proj_b.biases":{"data_offsets":[962907840,962915520],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.20.linear_attn.in_proj_b.scales":{"data_offsets":[1755088128,1755095808],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.20.linear_attn.in_proj_b.weight":{"data_offsets":[1510393056,1510515936],"dtype":"U32","shape":[48,640]},"model.language_model.layers.20.linear_attn.in_proj_qkv.biases":{"data_offsets":[2038630720,2040269120],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.20.linear_attn.in_proj_qkv.scales":{"data_offsets":[1699626144,1701264544],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.20.linear_attn.in_proj_qkv.weight":{"data_offsets":[1476969696,1496630496],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.20.linear_attn.in_proj_z.biases":{"data_offsets":[874546272,875529312],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.20.linear_attn.in_proj_z.scales":{"data_offsets":[1533358912,1534341952],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.20.linear_attn.in_proj_z.weight":{"data_offsets":[1463207136,1475003616],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.20.linear_attn.norm.weight":{"data_offsets":[1451392480,1451392736],"dtype":"BF16","shape":[128]},"model.language_model.layers.20.linear_attn.out_proj.biases":{"data_offsets":[1105500192,1106483232],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.20.linear_attn.out_proj.scales":{"data_offsets":[1140924448,1141907488],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.20.linear_attn.out_proj.weight":{"data_offsets":[1417313760,1429110240],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.20.mlp.down_proj.scales":{"data_offsets":[1352390112,1352424928],"dtype":"F16","shape":[17408]},"model.language_model.layers.20.mlp.down_proj.weight":{"data_offsets":[1352432608,1385855968],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.20.mlp.gate_proj.scales":{"data_offsets":[1703019680,1703054496],"dtype":"F16","shape":[17408]},"model.language_model.layers.20.mlp.gate_proj.weight":{"data_offsets":[1252120032,1285543392],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.20.mlp.up_proj.scales":{"data_offsets":[1251102176,1251136992],"dtype":"F16","shape":[17408]},"model.language_model.layers.20.mlp.up_proj.weight":{"data_offsets":[1318966752,1352390112],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.20.post_attention_layernorm.weight":{"data_offsets":[1251057120,1251067360],"dtype":"BF16","shape":[5120]},"model.language_model.layers.21.input_layernorm.weight":{"data_offsets":[1251012064,1251022304],"dtype":"BF16","shape":[5120]},"model.language_model.layers.21.linear_attn.A_log":{"data_offsets":[940575328,940575424],"dtype":"BF16","shape":[48]},"model.language_model.layers.21.linear_attn.conv1d.weight":{"data_offsets":[1701299360,1701381280],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.21.linear_attn.dt_bias":{"data_offsets":[1235283328,1235283424],"dtype":"BF16","shape":[48]},"model.language_model.layers.21.linear_attn.in_proj_a.biases":{"data_offsets":[1219381632,1219389312],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.21.linear_attn.in_proj_a.scales":{"data_offsets":[694367136,694374816],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.21.linear_attn.in_proj_a.weight":{"data_offsets":[1235125632,1235248512],"dtype":"U32","shape":[48,640]},"model.language_model.layers.21.linear_attn.in_proj_b.biases":{"data_offsets":[1184794496,1184802176],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.21.linear_attn.in_proj_b.scales":{"data_offsets":[1185915776,1185923456],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.21.linear_attn.in_proj_b.weight":{"data_offsets":[2067809600,2067932480],"dtype":"U32","shape":[48,640]},"model.language_model.layers.21.linear_attn.in_proj_qkv.biases":{"data_offsets":[1180499840,1182138240],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.21.linear_attn.in_proj_qkv.scales":{"data_offsets":[1183156096,1184794496],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.21.linear_attn.in_proj_qkv.weight":{"data_offsets":[1052415776,1072076576],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.21.linear_attn.in_proj_z.biases":{"data_offsets":[1165500800,1166483840],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.21.linear_attn.in_proj_z.scales":{"data_offsets":[1166565760,1167548800],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.21.linear_attn.in_proj_z.weight":{"data_offsets":[1168531840,1180328320],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.21.linear_attn.norm.weight":{"data_offsets":[1165500544,1165500800],"dtype":"BF16","shape":[128]},"model.language_model.layers.21.linear_attn.out_proj.biases":{"data_offsets":[1139941408,1140924448],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.21.linear_attn.out_proj.scales":{"data_offsets":[1184925056,1185908096],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.21.linear_attn.out_proj.weight":{"data_offsets":[1141907488,1153703968],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.21.mlp.down_proj.scales":{"data_offsets":[1106483232,1106518048],"dtype":"F16","shape":[17408]},"model.language_model.layers.21.mlp.down_proj.weight":{"data_offsets":[1106518048,1139941408],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.21.mlp.gate_proj.scales":{"data_offsets":[1755095904,1755130720],"dtype":"F16","shape":[17408]},"model.language_model.layers.21.mlp.gate_proj.weight":{"data_offsets":[1547896736,1570178976],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.21.mlp.up_proj.scales":{"data_offsets":[1219346816,1219381632],"dtype":"F16","shape":[17408]},"model.language_model.layers.21.mlp.up_proj.weight":{"data_offsets":[1072076576,1105499936],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.21.post_attention_layernorm.weight":{"data_offsets":[1052405536,1052415776],"dtype":"BF16","shape":[5120]},"model.language_model.layers.22.input_layernorm.weight":{"data_offsets":[1533266656,1533276896],"dtype":"BF16","shape":[5120]},"model.language_model.layers.22.linear_attn.A_log":{"data_offsets":[1807267168,1807267264],"dtype":"BF16","shape":[48]},"model.language_model.layers.22.linear_attn.conv1d.weight":{"data_offsets":[1018890016,1018971936],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.22.linear_attn.dt_bias":{"data_offsets":[1018882240,1018882336],"dtype":"BF16","shape":[48]},"model.language_model.layers.22.linear_attn.in_proj_a.biases":{"data_offsets":[2067932480,2067940160],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.22.linear_attn.in_proj_a.scales":{"data_offsets":[964029120,964036800],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.22.linear_attn.in_proj_a.weight":{"data_offsets":[997460160,997583040],"dtype":"U32","shape":[48,640]},"model.language_model.layers.22.linear_attn.in_proj_b.biases":{"data_offsets":[940567648,940575328],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.22.linear_attn.in_proj_b.scales":{"data_offsets":[943231680,943239360],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.22.linear_attn.in_proj_b.weight":{"data_offsets":[962915520,963038400],"dtype":"U32","shape":[48,640]},"model.language_model.layers.22.linear_attn.in_proj_qkv.biases":{"data_offsets":[1534341952,1535980352],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.22.linear_attn.in_proj_qkv.scales":{"data_offsets":[941593280,943231680],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.22.linear_attn.in_proj_qkv.weight":{"data_offsets":[943247040,962907840],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.22.linear_attn.in_proj_z.biases":{"data_offsets":[940575424,941558464],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.22.linear_attn.in_proj_z.scales":{"data_offsets":[716830112,717813152],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.22.linear_attn.in_proj_z.weight":{"data_offsets":[1755130720,1766927200],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.22.linear_attn.norm.weight":{"data_offsets":[1803334496,1803334752],"dtype":"BF16","shape":[128]},"model.language_model.layers.22.linear_attn.out_proj.biases":{"data_offsets":[1704737952,1705720992],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.22.linear_attn.out_proj.scales":{"data_offsets":[1604627872,1605610912],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.22.linear_attn.out_proj.weight":{"data_offsets":[875529312,887325792],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.22.mlp.down_proj.scales":{"data_offsets":[874511456,874546272],"dtype":"F16","shape":[17408]},"model.language_model.layers.22.mlp.down_proj.weight":{"data_offsets":[1018982176,1052405536],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.22.mlp.gate_proj.scales":{"data_offsets":[841053280,841088096],"dtype":"F16","shape":[17408]},"model.language_model.layers.22.mlp.gate_proj.weight":{"data_offsets":[841088096,874511456],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.22.mlp.up_proj.scales":{"data_offsets":[839042144,839076960],"dtype":"F16","shape":[17408]},"model.language_model.layers.22.mlp.up_proj.weight":{"data_offsets":[770372704,803796064],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.22.post_attention_layernorm.weight":{"data_offsets":[839031904,839042144],"dtype":"BF16","shape":[5120]},"model.language_model.layers.23.input_layernorm.weight":{"data_offsets":[839021664,839031904],"dtype":"BF16","shape":[5120]},"model.language_model.layers.23.mlp.down_proj.scales":{"data_offsets":[1547861408,1547896224],"dtype":"F16","shape":[17408]},"model.language_model.layers.23.mlp.down_proj.weight":{"data_offsets":[803796064,837219424],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.23.mlp.gate_proj.scales":{"data_offsets":[736709632,736744448],"dtype":"F16","shape":[17408]},"model.language_model.layers.23.mlp.gate_proj.weight":{"data_offsets":[1285543392,1318966752],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.23.mlp.up_proj.scales":{"data_offsets":[1701264544,1701299360],"dtype":"F16","shape":[17408]},"model.language_model.layers.23.mlp.up_proj.weight":{"data_offsets":[660943776,694367136],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.23.post_attention_layernorm.weight":{"data_offsets":[736699392,736709632],"dtype":"BF16","shape":[5120]},"model.language_model.layers.23.self_attn.k_norm.weight":{"data_offsets":[1385855968,1385856480],"dtype":"BF16","shape":[256]},"model.language_model.layers.23.self_attn.k_proj.biases":{"data_offsets":[736535552,736699392],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.23.self_attn.k_proj.scales":{"data_offsets":[1180336000,1180499840],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.23.self_attn.k_proj.weight":{"data_offsets":[1895463360,1898084800],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.23.self_attn.o_proj.biases":{"data_offsets":[963038400,964021440],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.23.self_attn.o_proj.scales":{"data_offsets":[2037647680,2038630720],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.23.self_attn.o_proj.weight":{"data_offsets":[1705925792,1721654432],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.23.self_attn.q_norm.weight":{"data_offsets":[717813152,717813664],"dtype":"BF16","shape":[256]},"model.language_model.layers.23.self_attn.q_proj.biases":{"data_offsets":[720729600,722695680],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.23.self_attn.q_proj.scales":{"data_offsets":[722765312,724731392],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.23.self_attn.q_proj.weight":{"data_offsets":[1385856480,1417313760],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.23.self_attn.v_proj.biases":{"data_offsets":[838857824,839021664],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.23.self_attn.v_proj.scales":{"data_offsets":[717936640,718100480],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.23.self_attn.v_proj.weight":{"data_offsets":[718108160,720729600],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.24.input_layernorm.weight":{"data_offsets":[839076960,839087200],"dtype":"BF16","shape":[5120]},"model.language_model.layers.24.linear_attn.A_log":{"data_offsets":[1956164320,1956164416],"dtype":"BF16","shape":[48]},"model.language_model.layers.24.linear_attn.conv1d.weight":{"data_offsets":[635138976,635220896],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.24.linear_attn.dt_bias":{"data_offsets":[717813664,717813760],"dtype":"BF16","shape":[48]},"model.language_model.layers.24.linear_attn.in_proj_a.biases":{"data_offsets":[716787616,716795296],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.24.linear_attn.in_proj_a.scales":{"data_offsets":[718100480,718108160],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.24.linear_attn.in_proj_a.weight":{"data_offsets":[716664736,716787616],"dtype":"U32","shape":[48,640]},"model.language_model.layers.24.linear_attn.in_proj_b.biases":{"data_offsets":[1018882336,1018890016],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.24.linear_attn.in_proj_b.scales":{"data_offsets":[694374816,694382496],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.24.linear_attn.in_proj_b.weight":{"data_offsets":[1684627104,1684749984],"dtype":"U32","shape":[48,640]},"model.language_model.layers.24.linear_attn.in_proj_qkv.biases":{"data_offsets":[635220896,636859296],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.24.linear_attn.in_proj_qkv.scales":{"data_offsets":[637023136,638661536],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.24.linear_attn.in_proj_qkv.weight":{"data_offsets":[638661536,658322336],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.24.linear_attn.in_proj_z.biases":{"data_offsets":[1475986656,1476969696],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.24.linear_attn.in_proj_z.scales":{"data_offsets":[634155936,635138976],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.24.linear_attn.in_proj_z.weight":{"data_offsets":[2056013120,2067809600],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.24.linear_attn.norm.weight":{"data_offsets":[634120864,634121120],"dtype":"BF16","shape":[128]},"model.language_model.layers.24.linear_attn.out_proj.biases":{"data_offsets":[1806283872,1807266912],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.24.linear_attn.out_proj.scales":{"data_offsets":[1182173056,1183156096],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.24.linear_attn.out_proj.weight":{"data_offsets":[622324384,634120864],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.24.mlp.down_proj.scales":{"data_offsets":[555319968,555354784],"dtype":"F16","shape":[17408]},"model.language_model.layers.24.mlp.down_proj.weight":{"data_offsets":[555354784,588778144],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.24.mlp.gate_proj.scales":{"data_offsets":[521861792,521896608],"dtype":"F16","shape":[17408]},"model.language_model.layers.24.mlp.gate_proj.weight":{"data_offsets":[521896608,555319968],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.24.mlp.up_proj.scales":{"data_offsets":[1235248512,1235283328],"dtype":"F16","shape":[17408]},"model.language_model.layers.24.mlp.up_proj.weight":{"data_offsets":[488315552,521738912],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.24.post_attention_layernorm.weight":{"data_offsets":[488297632,488307872],"dtype":"BF16","shape":[5120]},"model.language_model.layers.25.input_layernorm.weight":{"data_offsets":[488287392,488297632],"dtype":"BF16","shape":[5120]},"model.language_model.layers.25.linear_attn.A_log":{"data_offsets":[488287296,488287392],"dtype":"BF16","shape":[48]},"model.language_model.layers.25.linear_attn.conv1d.weight":{"data_offsets":[770290784,770372704],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.25.linear_attn.dt_bias":{"data_offsets":[488287200,488287296],"dtype":"BF16","shape":[48]},"model.language_model.layers.25.linear_attn.in_proj_a.biases":{"data_offsets":[487091584,487099264],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.25.linear_attn.in_proj_a.scales":{"data_offsets":[943239360,943247040],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.25.linear_attn.in_proj_a.weight":{"data_offsets":[487099360,487222240],"dtype":"U32","shape":[48,640]},"model.language_model.layers.25.linear_attn.in_proj_b.biases":{"data_offsets":[486093184,486100864],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.25.linear_attn.in_proj_b.scales":{"data_offsets":[487083904,487091584],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.25.linear_attn.in_proj_b.weight":{"data_offsets":[622201504,622324384],"dtype":"U32","shape":[48,640]},"model.language_model.layers.25.linear_attn.in_proj_qkv.biases":{"data_offsets":[429732224,431370624],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.25.linear_attn.in_proj_qkv.scales":{"data_offsets":[431370624,433009024],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.25.linear_attn.in_proj_qkv.weight":{"data_offsets":[433009024,452669824],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.25.linear_attn.in_proj_z.biases":{"data_offsets":[1805300832,1806283872],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.25.linear_attn.in_proj_z.scales":{"data_offsets":[1543064992,1544048032],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.25.linear_attn.in_proj_z.weight":{"data_offsets":[1219389312,1235117952],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.25.linear_attn.norm.weight":{"data_offsets":[428093568,428093824],"dtype":"BF16","shape":[128]},"model.language_model.layers.25.linear_attn.out_proj.biases":{"data_offsets":[427110528,428093568],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.25.linear_attn.out_proj.scales":{"data_offsets":[1898084800,1899067840],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.25.linear_attn.out_proj.weight":{"data_offsets":[1496630496,1508426976],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.25.mlp.down_proj.scales":{"data_offsets":[1989753152,1989787968],"dtype":"F16","shape":[17408]},"model.language_model.layers.25.mlp.down_proj.weight":{"data_offsets":[1571204512,1604627872],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.25.mlp.gate_proj.scales":{"data_offsets":[716795296,716830112],"dtype":"F16","shape":[17408]},"model.language_model.layers.25.mlp.gate_proj.weight":{"data_offsets":[736867424,770290784],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.25.mlp.up_proj.scales":{"data_offsets":[722695680,722730496],"dtype":"F16","shape":[17408]},"model.language_model.layers.25.mlp.up_proj.weight":{"data_offsets":[1721654528,1755077888],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.25.post_attention_layernorm.weight":{"data_offsets":[427100288,427110528],"dtype":"BF16","shape":[5120]},"model.language_model.layers.26.input_layernorm.weight":{"data_offsets":[427082368,427092608],"dtype":"BF16","shape":[5120]},"model.language_model.layers.26.linear_attn.A_log":{"data_offsets":[487099264,487099360],"dtype":"BF16","shape":[48]},"model.language_model.layers.26.linear_attn.conv1d.weight":{"data_offsets":[488205280,488287200],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.26.linear_attn.dt_bias":{"data_offsets":[1165500448,1165500544],"dtype":"BF16","shape":[48]},"model.language_model.layers.26.linear_attn.in_proj_a.biases":{"data_offsets":[426909312,426916992],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.26.linear_attn.in_proj_a.scales":{"data_offsets":[426916992,426924672],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.26.linear_attn.in_proj_a.weight":{"data_offsets":[426924672,427047552],"dtype":"U32","shape":[48,640]},"model.language_model.layers.26.linear_attn.in_proj_b.biases":{"data_offsets":[1990781248,1990788928],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.26.linear_attn.in_proj_b.scales":{"data_offsets":[1532972256,1532979936],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.26.linear_attn.in_proj_b.weight":{"data_offsets":[521738912,521861792],"dtype":"U32","shape":[48,640]},"model.language_model.layers.26.linear_attn.in_proj_qkv.biases":{"data_offsets":[1017243840,1018882240],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.26.linear_attn.in_proj_qkv.scales":{"data_offsets":[428093824,429732224],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.26.linear_attn.in_proj_qkv.weight":{"data_offsets":[920783968,940444768],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.26.linear_attn.in_proj_z.biases":{"data_offsets":[486100864,487083904],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.26.linear_attn.in_proj_z.scales":{"data_offsets":[425926272,426909312],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.26.linear_attn.in_proj_z.weight":{"data_offsets":[724739072,736535552],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.26.linear_attn.norm.weight":{"data_offsets":[1105499936,1105500192],"dtype":"BF16","shape":[128]},"model.language_model.layers.26.linear_attn.out_proj.biases":{"data_offsets":[379723392,380706432],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.26.linear_attn.out_proj.scales":{"data_offsets":[1251136992,1252120032],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.26.linear_attn.out_proj.weight":{"data_offsets":[380706432,392502912],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.26.mlp.down_proj.scales":{"data_offsets":[379688576,379723392],"dtype":"F16","shape":[17408]},"model.language_model.layers.26.mlp.down_proj.weight":{"data_offsets":[1185923456,1219346816],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.26.mlp.gate_proj.scales":{"data_offsets":[346230400,346265216],"dtype":"F16","shape":[17408]},"model.language_model.layers.26.mlp.gate_proj.weight":{"data_offsets":[1956294976,1989718336],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.26.mlp.up_proj.scales":{"data_offsets":[1251067360,1251102176],"dtype":"F16","shape":[17408]},"model.language_model.layers.26.mlp.up_proj.weight":{"data_offsets":[312807040,346230400],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.26.post_attention_layernorm.weight":{"data_offsets":[1921911424,1921921664],"dtype":"BF16","shape":[5120]},"model.language_model.layers.27.input_layernorm.weight":{"data_offsets":[312796800,312807040],"dtype":"BF16","shape":[5120]},"model.language_model.layers.27.mlp.down_proj.scales":{"data_offsets":[312761984,312796800],"dtype":"F16","shape":[17408]},"model.language_model.layers.27.mlp.down_proj.weight":{"data_offsets":[887360608,920783968],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.27.mlp.gate_proj.scales":{"data_offsets":[1543030176,1543064992],"dtype":"F16","shape":[17408]},"model.language_model.layers.27.mlp.gate_proj.weight":{"data_offsets":[279338624,312761984],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.27.mlp.up_proj.scales":{"data_offsets":[427047552,427082368],"dtype":"F16","shape":[17408]},"model.language_model.layers.27.mlp.up_proj.weight":{"data_offsets":[245915264,279338624],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.27.post_attention_layernorm.weight":{"data_offsets":[245905024,245915264],"dtype":"BF16","shape":[5120]},"model.language_model.layers.27.self_attn.k_norm.weight":{"data_offsets":[245904512,245905024],"dtype":"BF16","shape":[256]},"model.language_model.layers.27.self_attn.k_proj.biases":{"data_offsets":[1533102816,1533266656],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.27.self_attn.k_proj.scales":{"data_offsets":[245740672,245904512],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.27.self_attn.k_proj.weight":{"data_offsets":[658322336,660943776],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.27.self_attn.o_proj.biases":{"data_offsets":[487222240,488205280],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.27.self_attn.o_proj.scales":{"data_offsets":[244757632,245740672],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.27.self_attn.o_proj.weight":{"data_offsets":[2040276800,2056005440],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.27.self_attn.q_norm.weight":{"data_offsets":[2024212288,2024212800],"dtype":"BF16","shape":[256]},"model.language_model.layers.27.self_attn.q_proj.biases":{"data_offsets":[242791552,244757632],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.27.self_attn.q_proj.scales":{"data_offsets":[964036800,966002880],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.27.self_attn.q_proj.weight":{"data_offsets":[966002880,997460160],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.27.self_attn.v_proj.biases":{"data_offsets":[242463776,242627616],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.27.self_attn.v_proj.scales":{"data_offsets":[242627712,242791552],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.27.self_attn.v_proj.weight":{"data_offsets":[1538612128,1541233568],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.28.input_layernorm.weight":{"data_offsets":[1990771008,1990781248],"dtype":"BF16","shape":[5120]},"model.language_model.layers.28.linear_attn.A_log":{"data_offsets":[736867328,736867424],"dtype":"BF16","shape":[48]},"model.language_model.layers.28.linear_attn.conv1d.weight":{"data_offsets":[242381856,242463776],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.28.linear_attn.dt_bias":{"data_offsets":[242627616,242627712],"dtype":"BF16","shape":[48]},"model.language_model.layers.28.linear_attn.in_proj_a.biases":{"data_offsets":[427092608,427100288],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.28.linear_attn.in_proj_a.scales":{"data_offsets":[242374176,242381856],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.28.linear_attn.in_proj_a.weight":{"data_offsets":[717813760,717936640],"dtype":"U32","shape":[48,640]},"model.language_model.layers.28.linear_attn.in_proj_b.biases":{"data_offsets":[1956287296,1956294976],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.28.linear_attn.in_proj_b.scales":{"data_offsets":[242366496,242374176],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.28.linear_attn.in_proj_b.weight":{"data_offsets":[736744448,736867328],"dtype":"U32","shape":[48,640]},"model.language_model.layers.28.linear_attn.in_proj_qkv.biases":{"data_offsets":[240728096,242366496],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.28.linear_attn.in_proj_qkv.scales":{"data_offsets":[238106656,239745056],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.28.linear_attn.in_proj_qkv.weight":{"data_offsets":[997583040,1017243840],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.28.linear_attn.in_proj_z.biases":{"data_offsets":[1475003616,1475986656],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.28.linear_attn.in_proj_z.scales":{"data_offsets":[1570221472,1571204512],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.28.linear_attn.in_proj_z.weight":{"data_offsets":[226310176,238106656],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.28.linear_attn.norm.weight":{"data_offsets":[226309920,226310176],"dtype":"BF16","shape":[128]},"model.language_model.layers.28.linear_attn.out_proj.biases":{"data_offsets":[1918728640,1919711680],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.28.linear_attn.out_proj.scales":{"data_offsets":[1627893152,1628876192],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.28.linear_attn.out_proj.weight":{"data_offsets":[2025851200,2037647680],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.28.mlp.down_proj.scales":{"data_offsets":[170569504,170604320],"dtype":"F16","shape":[17408]},"model.language_model.layers.28.mlp.down_proj.weight":{"data_offsets":[192886560,226309920],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.28.mlp.gate_proj.scales":{"data_offsets":[1182138240,1182173056],"dtype":"F16","shape":[17408]},"model.language_model.layers.28.mlp.gate_proj.weight":{"data_offsets":[137023264,170446624],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.28.mlp.up_proj.scales":{"data_offsets":[941558464,941593280],"dtype":"F16","shape":[17408]},"model.language_model.layers.28.mlp.up_proj.weight":{"data_offsets":[392502912,425926272],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.28.post_attention_layernorm.weight":{"data_offsets":[137013024,137023264],"dtype":"BF16","shape":[5120]},"model.language_model.layers.29.input_layernorm.weight":{"data_offsets":[137002784,137013024],"dtype":"BF16","shape":[5120]},"model.language_model.layers.29.linear_attn.A_log":{"data_offsets":[137002688,137002784],"dtype":"BF16","shape":[48]},"model.language_model.layers.29.linear_attn.conv1d.weight":{"data_offsets":[136920768,137002688],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.29.linear_attn.dt_bias":{"data_offsets":[136920672,136920768],"dtype":"BF16","shape":[48]},"model.language_model.layers.29.linear_attn.in_proj_a.biases":{"data_offsets":[1463199456,1463207136],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.29.linear_attn.in_proj_a.scales":{"data_offsets":[136912992,136920672],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.29.linear_attn.in_proj_a.weight":{"data_offsets":[1184802176,1184925056],"dtype":"U32","shape":[48,640]},"model.language_model.layers.29.linear_attn.in_proj_b.biases":{"data_offsets":[488307872,488315552],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.29.linear_attn.in_proj_b.scales":{"data_offsets":[724731392,724739072],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.29.linear_attn.in_proj_b.weight":{"data_offsets":[1684757664,1684880544],"dtype":"U32","shape":[48,640]},"model.language_model.layers.29.linear_attn.in_proj_qkv.biases":{"data_offsets":[837219424,838857824],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.29.linear_attn.in_proj_qkv.scales":{"data_offsets":[135264256,136902656],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.29.linear_attn.in_proj_qkv.weight":{"data_offsets":[2090222400,2109883200],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.29.linear_attn.in_proj_z.biases":{"data_offsets":[121501696,122484736],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.29.linear_attn.in_proj_z.scales":{"data_offsets":[122484736,123467776],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.29.linear_attn.in_proj_z.weight":{"data_offsets":[123467776,135264256],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.29.linear_attn.norm.weight":{"data_offsets":[121501440,121501696],"dtype":"BF16","shape":[128]},"model.language_model.layers.29.linear_attn.out_proj.biases":{"data_offsets":[119535360,120518400],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.29.linear_attn.out_proj.scales":{"data_offsets":[120518400,121501440],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.29.linear_attn.out_proj.weight":{"data_offsets":[1153703968,1165500448],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.29.mlp.down_proj.scales":{"data_offsets":[887325792,887360608],"dtype":"F16","shape":[17408]},"model.language_model.layers.29.mlp.down_proj.weight":{"data_offsets":[170604320,192886560],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.29.mlp.gate_proj.scales":{"data_offsets":[1662310048,1662344864],"dtype":"F16","shape":[17408]},"model.language_model.layers.29.mlp.gate_proj.weight":{"data_offsets":[452669824,486093184],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.29.mlp.up_proj.scales":{"data_offsets":[119500544,119535360],"dtype":"F16","shape":[17408]},"model.language_model.layers.29.mlp.up_proj.weight":{"data_offsets":[346265216,379688576],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.29.post_attention_layernorm.weight":{"data_offsets":[119490304,119500544],"dtype":"BF16","shape":[5120]},"model.language_model.layers.30.input_layernorm.weight":{"data_offsets":[136902752,136912992],"dtype":"BF16","shape":[5120]},"model.language_model.layers.30.linear_attn.A_log":{"data_offsets":[1933718144,1933718240],"dtype":"BF16","shape":[48]},"model.language_model.layers.30.linear_attn.conv1d.weight":{"data_offsets":[95487744,95569664],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.30.linear_attn.dt_bias":{"data_offsets":[136902656,136902752],"dtype":"BF16","shape":[48]},"model.language_model.layers.30.linear_attn.in_proj_a.biases":{"data_offsets":[95357184,95364864],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.30.linear_attn.in_proj_a.scales":{"data_offsets":[1684749984,1684757664],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.30.linear_attn.in_proj_a.weight":{"data_offsets":[95364864,95487744],"dtype":"U32","shape":[48,640]},"model.language_model.layers.30.linear_attn.in_proj_b.biases":{"data_offsets":[95341824,95349504],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.30.linear_attn.in_proj_b.scales":{"data_offsets":[95349504,95357184],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.30.linear_attn.in_proj_b.weight":{"data_offsets":[170446624,170569504],"dtype":"U32","shape":[48,640]},"model.language_model.layers.30.linear_attn.in_proj_qkv.biases":{"data_offsets":[117851904,119490304],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.30.linear_attn.in_proj_qkv.scales":{"data_offsets":[74042624,75681024],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.30.linear_attn.in_proj_qkv.weight":{"data_offsets":[75681024,95341824],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.30.linear_attn.in_proj_z.biases":{"data_offsets":[1544093088,1545076128],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.30.linear_attn.in_proj_z.scales":{"data_offsets":[61263104,62246144],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.30.linear_attn.in_proj_z.weight":{"data_offsets":[62246144,74042624],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.30.linear_attn.norm.weight":{"data_offsets":[61262848,61263104],"dtype":"BF16","shape":[128]},"model.language_model.layers.30.linear_attn.out_proj.biases":{"data_offsets":[48483328,49466368],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.30.linear_attn.out_proj.scales":{"data_offsets":[239745056,240728096],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.30.linear_attn.out_proj.weight":{"data_offsets":[49466368,61262848],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.30.mlp.down_proj.scales":{"data_offsets":[48448512,48483328],"dtype":"F16","shape":[17408]},"model.language_model.layers.30.mlp.down_proj.weight":{"data_offsets":[588778144,622201504],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.30.mlp.gate_proj.scales":{"data_offsets":[1921876608,1921911424],"dtype":"F16","shape":[17408]},"model.language_model.layers.30.mlp.gate_proj.weight":{"data_offsets":[26166272,48448512],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.30.mlp.up_proj.scales":{"data_offsets":[26131456,26166272],"dtype":"F16","shape":[17408]},"model.language_model.layers.30.mlp.up_proj.weight":{"data_offsets":[694382496,716664736],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.30.post_attention_layernorm.weight":{"data_offsets":[2143961920,2143972160],"dtype":"BF16","shape":[5120]},"model.language_model.layers.31.input_layernorm.weight":{"data_offsets":[1018971936,1018982176],"dtype":"BF16","shape":[5120]},"model.language_model.layers.31.mlp.down_proj.scales":{"data_offsets":[3814400,3849216],"dtype":"F16","shape":[17408]},"model.language_model.layers.31.mlp.down_proj.weight":{"data_offsets":[3849216,26131456],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.31.mlp.gate_proj.scales":{"data_offsets":[1251022304,1251057120],"dtype":"F16","shape":[17408]},"model.language_model.layers.31.mlp.gate_proj.weight":{"data_offsets":[95569664,117851904],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.31.mlp.up_proj.scales":{"data_offsets":[3779584,3814400],"dtype":"F16","shape":[17408]},"model.language_model.layers.31.mlp.up_proj.weight":{"data_offsets":[1839750080,1862032320],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.31.post_attention_layernorm.weight":{"data_offsets":[3769344,3779584],"dtype":"BF16","shape":[5120]},"model.language_model.layers.31.self_attn.k_norm.weight":{"data_offsets":[3768832,3769344],"dtype":"BF16","shape":[256]},"model.language_model.layers.31.self_attn.k_proj.biases":{"data_offsets":[636859296,637023136],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.31.self_attn.k_proj.scales":{"data_offsets":[983552,1147392],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.31.self_attn.k_proj.weight":{"data_offsets":[1147392,3768832],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.31.self_attn.o_proj.biases":{"data_offsets":[1766962016,1767945056],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.31.self_attn.o_proj.scales":{"data_offsets":[512,983552],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.31.self_attn.o_proj.weight":{"data_offsets":[1235283424,1251012064],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.31.self_attn.q_norm.weight":{"data_offsets":[0,512],"dtype":"BF16","shape":[256]}}"#
data_chars header2Chars header2

/-- Verbatim JSON header of `model-00004-of-00006.safetensors` (bytes 8 … 49400). -/
def header3 : String := r#"{"__metadata__":{"format":"mlx"},"model.language_model.layers.31.self_attn.q_proj.biases":{"data_offsets":[1718088352,1720054432],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.31.self_attn.q_proj.scales":{"data_offsets":[1714438816,1716404896],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.31.self_attn.q_proj.weight":{"data_offsets":[2060022496,2091479776],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.31.self_attn.v_proj.biases":{"data_offsets":[2134402880,2134566720],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.31.self_attn.v_proj.scales":{"data_offsets":[1922076704,1922240544],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.31.self_attn.v_proj.weight":{"data_offsets":[1032193888,1034815328],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.32.input_layernorm.weight":{"data_offsets":[1032175872,1032186112],"dtype":"BF16","shape":[5120]},"model.language_model.layers.32.linear_attn.A_log":{"data_offsets":[2023954560,2023954656],"dtype":"BF16","shape":[48]},"model.language_model.layers.32.linear_attn.conv1d.weight":{"data_offsets":[2098808640,2098890560],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.32.linear_attn.dt_bias":{"data_offsets":[1564544064,1564544160],"dtype":"BF16","shape":[48]},"model.language_model.layers.32.linear_attn.in_proj_a.biases":{"data_offsets":[2098800960,2098808640],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.32.linear_attn.in_proj_a.scales":{"data_offsets":[969211136,969218816],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.32.linear_attn.in_proj_a.weight":{"data_offsets":[1145545248,1145668128],"dtype":"U32","shape":[48,640]},"model.language_model.layers.32.linear_attn.in_proj_b.biases":{"data_offsets":[1979594880,1979602560],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.32.linear_attn.in_proj_b.scales":{"data_offsets":[2094463808,2094471488],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.32.linear_attn.in_proj_b.weight":{"data_offsets":[1899671584,1899794464],"dtype":"U32","shape":[48,640]},"model.language_model.layers.32.linear_attn.in_proj_qkv.biases":{"data_offsets":[1879182080,1880820480],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.32.linear_attn.in_proj_qkv.scales":{"data_offsets":[1562870848,1564509248],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.32.linear_attn.in_proj_qkv.weight":{"data_offsets":[626267712,645928512],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.32.linear_attn.in_proj_z.biases":{"data_offsets":[1720054432,1721037472],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.32.linear_attn.in_proj_z.scales":{"data_offsets":[1149103136,1150086176],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.32.linear_attn.in_proj_z.weight":{"data_offsets":[1664251040,1676047520],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.32.linear_attn.norm.weight":{"data_offsets":[2134636352,2134636608],"dtype":"BF16","shape":[128]},"model.language_model.layers.32.linear_attn.out_proj.biases":{"data_offsets":[2098890560,2099873600],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.32.linear_attn.out_proj.scales":{"data_offsets":[2099996480,2100979520],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.32.linear_attn.out_proj.weight":{"data_offsets":[1204568864,1216365344],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.32.mlp.down_proj.scales":{"data_offsets":[1899513888,1899548704],"dtype":"F16","shape":[17408]},"model.language_model.layers.32.mlp.down_proj.weight":{"data_offsets":[1899794464,1922076704],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.32.mlp.gate_proj.scales":{"data_offsets":[1778744064,1778778880],"dtype":"F16","shape":[17408]},"model.language_model.layers.32.mlp.gate_proj.weight":{"data_offsets":[1856776960,1879059200],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.32.mlp.up_proj.scales":{"data_offsets":[1561197632,1561232448],"dtype":"F16","shape":[17408]},"model.language_model.layers.32.mlp.up_proj.weight":{"data_offsets":[1721037472,1743319712],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.32.post_attention_layernorm.weight":{"data_offsets":[1355859680,1355869920],"dtype":"BF16","shape":[5120]},"model.language_model.layers.33.input_layernorm.weight":{"data_offsets":[1979637376,1979647616],"dtype":"BF16","shape":[5120]},"model.language_model.layers.33.linear_attn.A_log":{"data_offsets":[1778743968,1778744064],"dtype":"BF16","shape":[48]},"model.language_model.layers.33.linear_attn.conv1d.weight":{"data_offsets":[1565537440,1565619360],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.33.linear_attn.dt_bias":{"data_offsets":[1979594784,1979594880],"dtype":"BF16","shape":[48]},"model.language_model.layers.33.linear_attn.in_proj_a.biases":{"data_offsets":[1899506208,1899513888],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.33.linear_attn.in_proj_a.scales":{"data_offsets":[1880820576,1880828256],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.33.linear_attn.in_proj_a.weight":{"data_offsets":[1234090880,1234213760],"dtype":"U32","shape":[48,640]},"model.language_model.layers.33.linear_attn.in_proj_b.biases":{"data_offsets":[2060014816,2060022496],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.33.linear_attn.in_proj_b.scales":{"data_offsets":[1677808800,1677816480],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.33.linear_attn.in_proj_b.weight":{"data_offsets":[1677816480,1677939360],"dtype":"U32","shape":[48,640]},"model.language_model.layers.33.linear_attn.in_proj_qkv.biases":{"data_offsets":[1565619360,1567257760],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.33.linear_attn.in_proj_qkv.scales":{"data_offsets":[1232186144,1233824544],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.33.linear_attn.in_proj_qkv.weight":{"data_offsets":[1693749920,1713410720],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.33.linear_attn.in_proj_z.biases":{"data_offsets":[1662284960,1663268000],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.33.linear_attn.in_proj_z.scales":{"data_offsets":[1564544160,1565527200],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.33.linear_attn.in_proj_z.weight":{"data_offsets":[2000361088,2012157568],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.33.linear_attn.norm.weight":{"data_offsets":[1559153984,1559154240],"dtype":"BF16","shape":[128]},"model.language_model.layers.33.linear_attn.out_proj.biases":{"data_offsets":[972858112,973841152],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.33.linear_attn.out_proj.scales":{"data_offsets":[1459569728,1460552768],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.33.linear_attn.out_proj.weight":{"data_offsets":[1480346688,1492143168],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.33.mlp.down_proj.scales":{"data_offsets":[1718053536,1718088352],"dtype":"F16","shape":[17408]},"model.language_model.layers.33.mlp.down_proj.weight":{"data_offsets":[838695840,860978080],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.33.mlp.gate_proj.scales":{"data_offsets":[1759048352,1759083168],"dtype":"F16","shape":[17408]},"model.language_model.layers.33.mlp.gate_proj.weight":{"data_offsets":[1811219200,1833501440],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.33.mlp.up_proj.scales":{"data_offsets":[1979602560,1979637376],"dtype":"F16","shape":[17408]},"model.language_model.layers.33.mlp.up_proj.weight":{"data_offsets":[1425490752,1447772992],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.33.post_attention_layernorm.weight":{"data_offsets":[1565527200,1565537440],"dtype":"BF16","shape":[5120]},"model.language_model.layers.34.input_layernorm.weight":{"data_offsets":[793945408,793955648],"dtype":"BF16","shape":[5120]},"model.language_model.layers.34.linear_attn.A_log":{"data_offsets":[1323342720,1323342816],"dtype":"BF16","shape":[48]},"model.language_model.layers.34.linear_attn.conv1d.weight":{"data_offsets":[1424425792,1424507712],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.34.linear_attn.dt_bias":{"data_offsets":[1389303520,1389303616],"dtype":"BF16","shape":[48]},"model.language_model.layers.34.linear_attn.in_proj_a.biases":{"data_offsets":[1336140768,1336148448],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.34.linear_attn.in_proj_a.scales":{"data_offsets":[1336156128,1336163808],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.34.linear_attn.in_proj_a.weight":{"data_offsets":[778943552,779066432],"dtype":"U32","shape":[48,640]},"model.language_model.layers.34.linear_attn.in_proj_b.biases":{"data_offsets":[1184701728,1184709408],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.34.linear_attn.in_proj_b.scales":{"data_offsets":[1336132576,1336140256],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.34.linear_attn.in_proj_b.weight":{"data_offsets":[1676047520,1676170400],"dtype":"U32","shape":[48,640]},"model.language_model.layers.34.linear_attn.in_proj_qkv.biases":{"data_offsets":[1422744896,1424383296],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.34.linear_attn.in_proj_qkv.scales":{"data_offsets":[1567257760,1568896160],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.34.linear_attn.in_proj_qkv.weight":{"data_offsets":[1184908064,1204568864],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.34.linear_attn.in_proj_z.biases":{"data_offsets":[1424507712,1425490752],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.34.linear_attn.in_proj_z.scales":{"data_offsets":[1323342816,1324325856],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.34.linear_attn.in_proj_z.weight":{"data_offsets":[1324325856,1336122336],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.34.linear_attn.norm.weight":{"data_offsets":[1336163808,1336164064],"dtype":"BF16","shape":[128]},"model.language_model.layers.34.linear_attn.out_proj.biases":{"data_offsets":[930818976,931802016],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.34.linear_attn.out_proj.scales":{"data_offsets":[1150120992,1151104032],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.34.linear_attn.out_proj.weight":{"data_offsets":[2012158080,2023954560],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.34.mlp.down_proj.scales":{"data_offsets":[1148945440,1148980256],"dtype":"F16","shape":[17408]},"model.language_model.layers.34.mlp.down_proj.weight":{"data_offsets":[1267637120,1301060480],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.34.mlp.gate_proj.scales":{"data_offsets":[1150086176,1150120992],"dtype":"F16","shape":[17408]},"model.language_model.layers.34.mlp.gate_proj.weight":{"data_offsets":[1301060480,1323342720],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.34.mlp.up_proj.scales":{"data_offsets":[2097092928,2097127744],"dtype":"F16","shape":[17408]},"model.language_model.layers.34.mlp.up_proj.weight":{"data_offsets":[1834494720,1856776960],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.34.post_attention_layernorm.weight":{"data_offsets":[1233834880,1233845120],"dtype":"BF16","shape":[5120]},"model.language_model.layers.35.input_layernorm.weight":{"data_offsets":[1216365344,1216375584],"dtype":"BF16","shape":[5120]},"model.language_model.layers.35.mlp.down_proj.scales":{"data_offsets":[1564509248,1564544064],"dtype":"F16","shape":[17408]},"model.language_model.layers.35.mlp.down_proj.weight":{"data_offsets":[1151114528,1184537888],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.35.mlp.gate_proj.scales":{"data_offsets":[2092462912,2092497728],"dtype":"F16","shape":[17408]},"model.language_model.layers.35.mlp.gate_proj.weight":{"data_offsets":[990225152,1012507392],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.35.mlp.up_proj.scales":{"data_offsets":[1559154240,1559189056],"dtype":"F16","shape":[17408]},"model.language_model.layers.35.mlp.up_proj.weight":{"data_offsets":[1234213760,1267637120],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.35.post_attention_layernorm.weight":{"data_offsets":[1151104288,1151114528],"dtype":"BF16","shape":[5120]},"model.language_model.layers.35.self_attn.k_norm.weight":{"data_offsets":[1148944928,1148945440],"dtype":"BF16","shape":[256]},"model.language_model.layers.35.self_attn.k_proj.biases":{"data_offsets":[1105398720,1105562560],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.35.self_attn.k_proj.scales":{"data_offsets":[1142759968,1142923808],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.35.self_attn.k_proj.weight":{"data_offsets":[1142923808,1145545248],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.35.self_attn.o_proj.biases":{"data_offsets":[974824192,975807232],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.35.self_attn.o_proj.scales":{"data_offsets":[525006912,525989952],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.35.self_attn.o_proj.weight":{"data_offsets":[1569879200,1585607840],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.35.self_attn.q_norm.weight":{"data_offsets":[2012157568,2012158080],"dtype":"BF16","shape":[256]},"model.language_model.layers.35.self_attn.q_proj.biases":{"data_offsets":[1897540128,1899506208],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.35.self_attn.q_proj.scales":{"data_offsets":[797701024,799667104],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.35.self_attn.q_proj.weight":{"data_offsets":[1585607840,1617065120],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.35.self_attn.v_proj.biases":{"data_offsets":[778779712,778943552],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.35.self_attn.v_proj.scales":{"data_offsets":[1184537888,1184701728],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.35.self_attn.v_proj.weight":{"data_offsets":[1105615392,1108236832],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.36.input_layernorm.weight":{"data_offsets":[1105605152,1105615392],"dtype":"BF16","shape":[5120]},"model.language_model.layers.36.linear_attn.A_log":{"data_offsets":[1105597376,1105597472],"dtype":"BF16","shape":[48]},"model.language_model.layers.36.linear_attn.conv1d.weight":{"data_offsets":[1105316800,1105398720],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.36.linear_attn.dt_bias":{"data_offsets":[1102695264,1102695360],"dtype":"BF16","shape":[48]},"model.language_model.layers.36.linear_attn.in_proj_a.biases":{"data_offsets":[1032186112,1032193792],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.36.linear_attn.in_proj_a.scales":{"data_offsets":[1068246368,1068254048],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.36.linear_attn.in_proj_a.weight":{"data_offsets":[1480223808,1480346688],"dtype":"U32","shape":[48,640]},"model.language_model.layers.36.linear_attn.in_proj_b.biases":{"data_offsets":[1561189952,1561197632],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.36.linear_attn.in_proj_b.scales":{"data_offsets":[1105597472,1105605152],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.36.linear_attn.in_proj_b.weight":{"data_offsets":[1899548704,1899671584],"dtype":"U32","shape":[48,640]},"model.language_model.layers.36.linear_attn.in_proj_qkv.biases":{"data_offsets":[965606656,967245056],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.36.linear_attn.in_proj_qkv.scales":{"data_offsets":[2094471488,2096109888],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.36.linear_attn.in_proj_qkv.weight":{"data_offsets":[1012507392,1032168192],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.36.linear_attn.in_proj_z.biases":{"data_offsets":[969218816,970201856],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.36.linear_attn.in_proj_z.scales":{"data_offsets":[973841152,974824192],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.36.linear_attn.in_proj_z.weight":{"data_offsets":[1447772992,1459569472],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.36.linear_attn.norm.weight":{"data_offsets":[1559153728,1559153984],"dtype":"BF16","shape":[128]},"model.language_model.layers.36.linear_attn.out_proj.biases":{"data_offsets":[1880828352,1881811392],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.36.linear_attn.out_proj.scales":{"data_offsets":[967245056,968228096],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.36.linear_attn.out_proj.weight":{"data_offsets":[953697792,965494272],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.36.mlp.down_proj.scales":{"data_offsets":[965564160,965598976],"dtype":"F16","shape":[17408]},"model.language_model.layers.36.mlp.down_proj.weight":{"data_offsets":[1944522784,1977946144],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.36.mlp.gate_proj.scales":{"data_offsets":[965529344,965564160],"dtype":"F16","shape":[17408]},"model.language_model.layers.36.mlp.gate_proj.weight":{"data_offsets":[1922240544,1944522784],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.36.mlp.up_proj.scales":{"data_offsets":[965494528,965529344],"dtype":"F16","shape":[17408]},"model.language_model.layers.36.mlp.up_proj.weight":{"data_offsets":[1068288864,1101712224],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.36.post_attention_layernorm.weight":{"data_offsets":[872774560,872784800],"dtype":"BF16","shape":[5120]},"model.language_model.layers.37.input_layernorm.weight":{"data_offsets":[1389303616,1389313856],"dtype":"BF16","shape":[5120]},"model.language_model.layers.37.linear_attn.A_log":{"data_offsets":[953697696,953697792],"dtype":"BF16","shape":[48]},"model.language_model.layers.37.linear_attn.conv1d.weight":{"data_offsets":[931802016,931883936],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.37.linear_attn.dt_bias":{"data_offsets":[2091479776,2091479872],"dtype":"BF16","shape":[48]},"model.language_model.layers.37.linear_attn.in_proj_a.biases":{"data_offsets":[953436576,953444256],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.37.linear_attn.in_proj_a.scales":{"data_offsets":[953444256,953451936],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.37.linear_attn.in_proj_a.weight":{"data_offsets":[953574816,953697696],"dtype":"U32","shape":[48,640]},"model.language_model.layers.37.linear_attn.in_proj_b.biases":{"data_offsets":[953346976,953354656],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.37.linear_attn.in_proj_b.scales":{"data_offsets":[1034815328,1034823008],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.37.linear_attn.in_proj_b.weight":{"data_offsets":[1148980256,1149103136],"dtype":"U32","shape":[48,640]},"model.language_model.layers.37.linear_attn.in_proj_qkv.biases":{"data_offsets":[1716415136,1718053536],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.37.linear_attn.in_proj_qkv.scales":{"data_offsets":[931883936,933522336],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.37.linear_attn.in_proj_qkv.weight":{"data_offsets":[933686176,953346976],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.37.linear_attn.in_proj_z.biases":{"data_offsets":[872784800,873767840],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.37.linear_attn.in_proj_z.scales":{"data_offsets":[970201856,971184896],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.37.linear_attn.in_proj_z.weight":{"data_offsets":[873802656,885599136],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.37.linear_attn.norm.weight":{"data_offsets":[965494272,965494528],"dtype":"BF16","shape":[128]},"model.language_model.layers.37.linear_attn.out_proj.biases":{"data_offsets":[796717984,797701024],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.37.linear_attn.out_proj.scales":{"data_offsets":[1141776928,1142759968],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.37.linear_attn.out_proj.weight":{"data_offsets":[860978080,872774560],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.37.mlp.down_proj.scales":{"data_offsets":[1105562560,1105597376],"dtype":"F16","shape":[17408]},"model.language_model.layers.37.mlp.down_proj.weight":{"data_offsets":[1492143168,1525566528],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.37.mlp.gate_proj.scales":{"data_offsets":[1714404000,1714438816],"dtype":"F16","shape":[17408]},"model.language_model.layers.37.mlp.gate_proj.weight":{"data_offsets":[799701920,833125280],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.37.mlp.up_proj.scales":{"data_offsets":[799667104,799701920],"dtype":"F16","shape":[17408]},"model.language_model.layers.37.mlp.up_proj.weight":{"data_offsets":[525989952,559413312],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.37.post_attention_layernorm.weight":{"data_offsets":[1714393760,1714404000],"dtype":"BF16","shape":[5120]},"model.language_model.layers.38.input_layernorm.weight":{"data_offsets":[794078624,794088864],"dtype":"BF16","shape":[5120]},"model.language_model.layers.38.linear_attn.A_log":{"data_offsets":[794078528,794078624],"dtype":"BF16","shape":[48]},"model.language_model.layers.38.linear_attn.conv1d.weight":{"data_offsets":[953354656,953436576],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.38.linear_attn.dt_bias":{"data_offsets":[1233824544,1233824640],"dtype":"BF16","shape":[48]},"model.language_model.layers.38.linear_attn.in_proj_a.biases":{"data_offsets":[965598976,965606656],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.38.linear_attn.in_proj_a.scales":{"data_offsets":[1336148448,1336156128],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.38.linear_attn.in_proj_a.weight":{"data_offsets":[793955648,794078528],"dtype":"U32","shape":[48,640]},"model.language_model.layers.38.linear_attn.in_proj_b.biases":{"data_offsets":[592836672,592844352],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.38.linear_attn.in_proj_b.scales":{"data_offsets":[1424418112,1424425792],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.38.linear_attn.in_proj_b.weight":{"data_offsets":[1879059200,1879182080],"dtype":"U32","shape":[48,640]},"model.language_model.layers.38.linear_attn.in_proj_qkv.biases":{"data_offsets":[794088864,795727264],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.38.linear_attn.in_proj_qkv.scales":{"data_offsets":[975807232,977445632],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.38.linear_attn.in_proj_qkv.weight":{"data_offsets":[1979647616,1999308416],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.38.linear_attn.in_proj_z.biases":{"data_offsets":[1568896160,1569879200],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.38.linear_attn.in_proj_z.scales":{"data_offsets":[791846208,792829248],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.38.linear_attn.in_proj_z.weight":{"data_offsets":[919022496,930818976],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.38.linear_attn.norm.weight":{"data_offsets":[791845952,791846208],"dtype":"BF16","shape":[128]},"model.language_model.layers.38.linear_attn.out_proj.biases":{"data_offsets":[833125280,834108320],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.38.linear_attn.out_proj.scales":{"data_offsets":[779066432,780049472],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.38.linear_attn.out_proj.weight":{"data_offsets":[780049472,791845952],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.38.mlp.down_proj.scales":{"data_offsets":[971184896,971219712],"dtype":"F16","shape":[17408]},"model.language_model.layers.38.mlp.down_proj.weight":{"data_offsets":[713899072,747322432],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.38.mlp.gate_proj.scales":{"data_offsets":[2134601536,2134636352],"dtype":"F16","shape":[17408]},"model.language_model.layers.38.mlp.gate_proj.weight":{"data_offsets":[680475712,713899072],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.38.mlp.up_proj.scales":{"data_offsets":[1561155136,1561189952],"dtype":"F16","shape":[17408]},"model.language_model.layers.38.mlp.up_proj.weight":{"data_offsets":[2023962336,2057385696],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.38.post_attention_layernorm.weight":{"data_offsets":[680465472,680475712],"dtype":"BF16","shape":[5120]},"model.language_model.layers.39.input_layernorm.weight":{"data_offsets":[792829248,792839488],"dtype":"BF16","shape":[5120]},"model.language_model.layers.39.mlp.down_proj.scales":{"data_offsets":[2098766144,2098800960],"dtype":"F16","shape":[17408]},"model.language_model.layers.39.mlp.down_proj.weight":{"data_offsets":[645928512,679351872],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.39.mlp.gate_proj.scales":{"data_offsets":[1141742112,1141776928],"dtype":"F16","shape":[17408]},"model.language_model.layers.39.mlp.gate_proj.weight":{"data_offsets":[592844352,626267712],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.39.mlp.up_proj.scales":{"data_offsets":[1355824864,1355859680],"dtype":"F16","shape":[17408]},"model.language_model.layers.39.mlp.up_proj.weight":{"data_offsets":[559413312,592836672],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.39.post_attention_layernorm.weight":{"data_offsets":[1834484480,1834494720],"dtype":"BF16","shape":[5120]},"model.language_model.layers.39.self_attn.k_norm.weight":{"data_offsets":[525006400,525006912],"dtype":"BF16","shape":[256]},"model.language_model.layers.39.self_attn.k_proj.biases":{"data_offsets":[1558989888,1559153728],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.39.self_attn.k_proj.scales":{"data_offsets":[933522336,933686176],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.39.self_attn.k_proj.weight":{"data_offsets":[522384960,525006400],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.39.self_attn.o_proj.biases":{"data_offsets":[837712800,838695840],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.39.self_attn.o_proj.scales":{"data_offsets":[1713410720,1714393760],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.39.self_attn.o_proj.weight":{"data_offsets":[506656320,522384960],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.39.self_attn.q_norm.weight":{"data_offsets":[506655808,506656320],"dtype":"BF16","shape":[256]},"model.language_model.layers.39.self_attn.q_proj.biases":{"data_offsets":[1559189056,1561155136],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.39.self_attn.q_proj.scales":{"data_offsets":[485028928,486995008],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.39.self_attn.q_proj.weight":{"data_offsets":[1779761920,1811219200],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.39.self_attn.v_proj.biases":{"data_offsets":[462408768,462572608],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.39.self_attn.v_proj.scales":{"data_offsets":[482233408,482397248],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.39.self_attn.v_proj.weight":{"data_offsets":[482397248,485018688],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.4.linear_attn.in_proj_qkv.biases":{"data_offsets":[1561232448,1562870848],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.4.linear_attn.in_proj_qkv.scales":{"data_offsets":[1147306528,1148944928],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.4.linear_attn.in_proj_qkv.weight":{"data_offsets":[486995008,506655808],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.4.linear_attn.in_proj_z.biases":{"data_offsets":[460442688,461425728],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.4.linear_attn.in_proj_z.scales":{"data_offsets":[461425728,462408768],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.4.linear_attn.in_proj_z.weight":{"data_offsets":[1881811488,1897540128],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.4.linear_attn.norm.weight":{"data_offsets":[460442432,460442688],"dtype":"BF16","shape":[128]},"model.language_model.layers.4.linear_attn.out_proj.biases":{"data_offsets":[2091479872,2092462912],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.4.linear_attn.out_proj.scales":{"data_offsets":[1101712224,1102695264],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.4.linear_attn.out_proj.weight":{"data_offsets":[1743319712,1759048352],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.4.mlp.down_proj.scales":{"data_offsets":[1424383296,1424418112],"dtype":"F16","shape":[17408]},"model.language_model.layers.4.mlp.down_proj.weight":{"data_offsets":[427019072,460442432],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.4.mlp.gate_proj.scales":{"data_offsets":[360137536,360172352],"dtype":"F16","shape":[17408]},"model.language_model.layers.4.mlp.gate_proj.weight":{"data_offsets":[393595712,427019072],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.4.mlp.up_proj.scales":{"data_offsets":[359938880,359973696],"dtype":"F16","shape":[17408]},"model.language_model.layers.4.mlp.up_proj.weight":{"data_offsets":[1628861600,1662284960],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.4.post_attention_layernorm.weight":{"data_offsets":[359928640,359938880],"dtype":"BF16","shape":[5120]},"model.language_model.layers.40.input_layernorm.weight":{"data_offsets":[1480213568,1480223808],"dtype":"BF16","shape":[5120]},"model.language_model.layers.40.linear_attn.A_log":{"data_offsets":[136751648,136751744],"dtype":"BF16","shape":[48]},"model.language_model.layers.40.linear_attn.conv1d.weight":{"data_offsets":[1108236832,1108318752],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.40.linear_attn.dt_bias":{"data_offsets":[1880828256,1880828352],"dtype":"BF16","shape":[48]},"model.language_model.layers.40.linear_attn.in_proj_a.biases":{"data_offsets":[136621088,136628768],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.40.linear_attn.in_proj_a.scales":{"data_offsets":[1032168192,1032175872],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.40.linear_attn.in_proj_a.weight":{"data_offsets":[136628768,136751648],"dtype":"U32","shape":[48,640]},"model.language_model.layers.40.linear_attn.in_proj_b.biases":{"data_offsets":[2023954656,2023962336],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.40.linear_attn.in_proj_b.scales":{"data_offsets":[136613408,136621088],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.40.linear_attn.in_proj_b.weight":{"data_offsets":[2099873600,2099996480],"dtype":"U32","shape":[48,640]},"model.language_model.layers.40.linear_attn.in_proj_qkv.biases":{"data_offsets":[134975008,136613408],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.40.linear_attn.in_proj_qkv.scales":{"data_offsets":[1145668128,1147306528],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.40.linear_attn.in_proj_qkv.weight":{"data_offsets":[1336164064,1355824864],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.40.linear_attn.in_proj_z.biases":{"data_offsets":[133991968,134975008],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.40.linear_attn.in_proj_z.scales":{"data_offsets":[1663268000,1664251040],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.40.linear_attn.in_proj_z.weight":{"data_offsets":[1617065120,1628861600],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.40.linear_attn.norm.weight":{"data_offsets":[1151104032,1151104288],"dtype":"BF16","shape":[128]},"model.language_model.layers.40.linear_attn.out_proj.biases":{"data_offsets":[1999343232,2000326272],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.40.linear_attn.out_proj.scales":{"data_offsets":[121212448,122195488],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.40.linear_attn.out_proj.weight":{"data_offsets":[122195488,133991968],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.40.mlp.down_proj.scales":{"data_offsets":[87754272,87789088],"dtype":"F16","shape":[17408]},"model.language_model.layers.40.mlp.down_proj.weight":{"data_offsets":[87789088,121212448],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.40.mlp.gate_proj.scales":{"data_offsets":[54296096,54330912],"dtype":"F16","shape":[17408]},"model.language_model.layers.40.mlp.gate_proj.weight":{"data_offsets":[54330912,87754272],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.40.mlp.up_proj.scales":{"data_offsets":[2134566720,2134601536],"dtype":"F16","shape":[17408]},"model.language_model.layers.40.mlp.up_proj.weight":{"data_offsets":[305149408,338572768],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.40.post_attention_layernorm.weight":{"data_offsets":[1979584544,1979594784],"dtype":"BF16","shape":[5120]},"model.language_model.layers.41.input_layernorm.weight":{"data_offsets":[1716404896,1716415136],"dtype":"BF16","shape":[5120]},"model.language_model.layers.41.linear_attn.A_log":{"data_offsets":[54296000,54296096],"dtype":"BF16","shape":[48]},"model.language_model.layers.41.linear_attn.conv1d.weight":{"data_offsets":[54214080,54296000],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.41.linear_attn.dt_bias":{"data_offsets":[1881811392,1881811488],"dtype":"BF16","shape":[48]},"model.language_model.layers.41.linear_attn.in_proj_a.biases":{"data_offsets":[1389313856,1389321536],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.41.linear_attn.in_proj_a.scales":{"data_offsets":[54083520,54091200],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.41.linear_attn.in_proj_a.weight":{"data_offsets":[54091200,54214080],"dtype":"U32","shape":[48,640]},"model.language_model.layers.41.linear_attn.in_proj_b.biases":{"data_offsets":[680334912,680342592],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.41.linear_attn.in_proj_b.scales":{"data_offsets":[271583616,271591296],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.41.linear_attn.in_proj_b.weight":{"data_offsets":[53960640,54083520],"dtype":"U32","shape":[48,640]},"model.language_model.layers.41.linear_attn.in_proj_qkv.biases":{"data_offsets":[52322240,53960640],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.41.linear_attn.in_proj_qkv.scales":{"data_offsets":[2097127744,2098766144],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.41.linear_attn.in_proj_qkv.weight":{"data_offsets":[1759083168,1778743968],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.41.linear_attn.in_proj_z.biases":{"data_offsets":[792839488,793822528],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.41.linear_attn.in_proj_z.scales":{"data_offsets":[39542720,40525760],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.41.linear_attn.in_proj_z.weight":{"data_offsets":[40525760,52322240],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.41.linear_attn.norm.weight":{"data_offsets":[39542464,39542720],"dtype":"BF16","shape":[128]},"model.language_model.layers.41.linear_attn.out_proj.biases":{"data_offsets":[25779904,26762944],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.41.linear_attn.out_proj.scales":{"data_offsets":[26762944,27745984],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.41.linear_attn.out_proj.weight":{"data_offsets":[27745984,39542464],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.41.mlp.down_proj.scales":{"data_offsets":[25745088,25779904],"dtype":"F16","shape":[17408]},"model.language_model.layers.41.mlp.down_proj.weight":{"data_offsets":[885599136,919022496],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.41.mlp.gate_proj.scales":{"data_offsets":[1999308416,1999343232],"dtype":"F16","shape":[17408]},"model.language_model.layers.41.mlp.gate_proj.weight":{"data_offsets":[1355869920,1389293280],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.41.mlp.up_proj.scales":{"data_offsets":[25710272,25745088],"dtype":"F16","shape":[17408]},"model.language_model.layers.41.mlp.up_proj.weight":{"data_offsets":[2100979520,2134402880],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.41.post_attention_layernorm.weight":{"data_offsets":[25700032,25710272],"dtype":"BF16","shape":[5120]},"model.language_model.layers.42.input_layernorm.weight":{"data_offsets":[25689792,25700032],"dtype":"BF16","shape":[5120]},"model.language_model.layers.42.linear_attn.A_log":{"data_offsets":[25689696,25689792],"dtype":"BF16","shape":[48]},"model.language_model.layers.42.linear_attn.conv1d.weight":{"data_offsets":[1677939360,1678021280],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.42.linear_attn.dt_bias":{"data_offsets":[25689600,25689696],"dtype":"BF16","shape":[48]},"model.language_model.layers.42.linear_attn.in_proj_a.biases":{"data_offsets":[25559040,25566720],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.42.linear_attn.in_proj_a.scales":{"data_offsets":[796710304,796717984],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.42.linear_attn.in_proj_a.weight":{"data_offsets":[25566720,25689600],"dtype":"U32","shape":[48,640]},"model.language_model.layers.42.linear_attn.in_proj_b.biases":{"data_offsets":[2057385696,2057393376],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.42.linear_attn.in_proj_b.scales":{"data_offsets":[237489280,237496960],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.42.linear_attn.in_proj_b.weight":{"data_offsets":[1233845120,1233968000],"dtype":"U32","shape":[48,640]},"model.language_model.layers.42.linear_attn.in_proj_qkv.biases":{"data_offsets":[1977946144,1979584544],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.42.linear_attn.in_proj_qkv.scales":{"data_offsets":[971219712,972858112],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.42.linear_attn.in_proj_qkv.weight":{"data_offsets":[1460552768,1480213568],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.42.linear_attn.in_proj_z.biases":{"data_offsets":[679351872,680334912],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.42.linear_attn.in_proj_z.scales":{"data_offsets":[12779520,13762560],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.42.linear_attn.in_proj_z.weight":{"data_offsets":[13762560,25559040],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.42.linear_attn.norm.weight":{"data_offsets":[1459569472,1459569728],"dtype":"BF16","shape":[128]},"model.language_model.layers.42.linear_attn.out_proj.biases":{"data_offsets":[0,983040],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.42.linear_attn.out_proj.scales":{"data_offsets":[795727264,796710304],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.42.linear_attn.out_proj.weight":{"data_offsets":[983040,12779520],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.5.input_layernorm.weight":{"data_offsets":[485018688,485028928],"dtype":"BF16","shape":[5120]},"model.language_model.layers.5.linear_attn.A_log":{"data_offsets":[1880820480,1880820576],"dtype":"BF16","shape":[48]},"model.language_model.layers.5.linear_attn.conv1d.weight":{"data_offsets":[1232104224,1232186144],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.5.linear_attn.dt_bias":{"data_offsets":[359928544,359928640],"dtype":"BF16","shape":[48]},"model.language_model.layers.5.linear_attn.in_proj_a.biases":{"data_offsets":[359905504,359913184],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.5.linear_attn.in_proj_a.scales":{"data_offsets":[359920864,359928544],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.5.linear_attn.in_proj_a.weight":{"data_offsets":[1233968000,1234090880],"dtype":"U32","shape":[48,640]},"model.language_model.layers.5.linear_attn.in_proj_b.biases":{"data_offsets":[359890144,359897824],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.5.linear_attn.in_proj_b.scales":{"data_offsets":[359897824,359905504],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.5.linear_attn.in_proj_b.weight":{"data_offsets":[680342592,680465472],"dtype":"U32","shape":[48,640]},"model.language_model.layers.5.linear_attn.in_proj_qkv.biases":{"data_offsets":[1676170400,1677808800],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.5.linear_attn.in_proj_qkv.scales":{"data_offsets":[358251744,359890144],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.5.linear_attn.in_proj_qkv.weight":{"data_offsets":[462572608,482233408],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.5.linear_attn.in_proj_z.biases":{"data_offsets":[340546784,341529824],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.5.linear_attn.in_proj_z.scales":{"data_offsets":[2096109888,2097092928],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.5.linear_attn.in_proj_z.weight":{"data_offsets":[341540064,357268704],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.5.linear_attn.norm.weight":{"data_offsets":[340546528,340546784],"dtype":"BF16","shape":[128]},"model.language_model.layers.5.linear_attn.out_proj.biases":{"data_offsets":[338572768,339555808],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.5.linear_attn.out_proj.scales":{"data_offsets":[339563488,340546528],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.5.linear_attn.out_proj.weight":{"data_offsets":[1216375584,1232104224],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.5.mlp.down_proj.scales":{"data_offsets":[1068254048,1068288864],"dtype":"F16","shape":[17408]},"model.language_model.layers.5.mlp.down_proj.weight":{"data_offsets":[1108318752,1141742112],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.5.mlp.gate_proj.scales":{"data_offsets":[873767840,873802656],"dtype":"F16","shape":[17408]},"model.language_model.layers.5.mlp.gate_proj.weight":{"data_offsets":[1389321536,1422744896],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.5.mlp.up_proj.scales":{"data_offsets":[1184873248,1184908064],"dtype":"F16","shape":[17408]},"model.language_model.layers.5.mlp.up_proj.weight":{"data_offsets":[1525566528,1558989888],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.5.post_attention_layernorm.weight":{"data_offsets":[305139168,305149408],"dtype":"BF16","shape":[5120]},"model.language_model.layers.6.input_layernorm.weight":{"data_offsets":[1233824640,1233834880],"dtype":"BF16","shape":[5120]},"model.language_model.layers.6.linear_attn.A_log":{"data_offsets":[305139072,305139168],"dtype":"BF16","shape":[48]},"model.language_model.layers.6.linear_attn.conv1d.weight":{"data_offsets":[305057152,305139072],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.6.linear_attn.dt_bias":{"data_offsets":[1032193792,1032193888],"dtype":"BF16","shape":[48]},"model.language_model.layers.6.linear_attn.in_proj_a.biases":{"data_offsets":[359913184,359920864],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.6.linear_attn.in_proj_a.scales":{"data_offsets":[305049472,305057152],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.6.linear_attn.in_proj_a.weight":{"data_offsets":[953451936,953574816],"dtype":"U32","shape":[48,640]},"model.language_model.layers.6.linear_attn.in_proj_b.biases":{"data_offsets":[339555808,339563488],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.6.linear_attn.in_proj_b.scales":{"data_offsets":[271575936,271583616],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.6.linear_attn.in_proj_b.weight":{"data_offsets":[793822528,793945408],"dtype":"U32","shape":[48,640]},"model.language_model.layers.6.linear_attn.in_proj_qkv.biases":{"data_offsets":[836074400,837712800],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.6.linear_attn.in_proj_qkv.scales":{"data_offsets":[250276736,251915136],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.6.linear_attn.in_proj_qkv.weight":{"data_offsets":[251915136,271575936],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.6.linear_attn.in_proj_z.biases":{"data_offsets":[1778778880,1779761920],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.6.linear_attn.in_proj_z.scales":{"data_offsets":[968228096,969211136],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.6.linear_attn.in_proj_z.weight":{"data_offsets":[978428672,990225152],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.6.linear_attn.norm.weight":{"data_offsets":[250276480,250276736],"dtype":"BF16","shape":[128]},"model.language_model.layers.6.linear_attn.out_proj.biases":{"data_offsets":[977445632,978428672],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.6.linear_attn.out_proj.scales":{"data_offsets":[237496960,238480000],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.6.linear_attn.out_proj.weight":{"data_offsets":[238480000,250276480],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.6.mlp.down_proj.scales":{"data_offsets":[2000326272,2000361088],"dtype":"F16","shape":[17408]},"model.language_model.layers.6.mlp.down_proj.weight":{"data_offsets":[204065920,237489280],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.6.mlp.gate_proj.scales":{"data_offsets":[204031104,204065920],"dtype":"F16","shape":[17408]},"model.language_model.layers.6.mlp.gate_proj.weight":{"data_offsets":[360172352,393595712],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.6.mlp.up_proj.scales":{"data_offsets":[170409088,170443904],"dtype":"F16","shape":[17408]},"model.language_model.layers.6.mlp.up_proj.weight":{"data_offsets":[170443904,203867264],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.6.post_attention_layernorm.weight":{"data_offsets":[341529824,341540064],"dtype":"BF16","shape":[5120]},"model.language_model.layers.7.input_layernorm.weight":{"data_offsets":[1336122336,1336132576],"dtype":"BF16","shape":[5120]},"model.language_model.layers.7.mlp.down_proj.scales":{"data_offsets":[170374272,170409088],"dtype":"F16","shape":[17408]},"model.language_model.layers.7.mlp.down_proj.weight":{"data_offsets":[1034823008,1068246368],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.7.mlp.gate_proj.scales":{"data_offsets":[271591296,271626112],"dtype":"F16","shape":[17408]},"model.language_model.layers.7.mlp.gate_proj.weight":{"data_offsets":[271626112,305049472],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.7.mlp.up_proj.scales":{"data_offsets":[136916096,136950912],"dtype":"F16","shape":[17408]},"model.language_model.layers.7.mlp.up_proj.weight":{"data_offsets":[136950912,170374272],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.7.post_attention_layernorm.weight":{"data_offsets":[1389293280,1389303520],"dtype":"BF16","shape":[5120]},"model.language_model.layers.7.self_attn.k_norm.weight":{"data_offsets":[1336140256,1336140768],"dtype":"BF16","shape":[256]},"model.language_model.layers.7.self_attn.k_proj.biases":{"data_offsets":[1184709408,1184873248],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.7.self_attn.k_proj.scales":{"data_offsets":[203867264,204031104],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.7.self_attn.k_proj.weight":{"data_offsets":[1102695360,1105316800],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.7.self_attn.o_proj.biases":{"data_offsets":[1833501440,1834484480],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.7.self_attn.o_proj.scales":{"data_offsets":[357268704,358251744],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.7.self_attn.o_proj.weight":{"data_offsets":[1678021280,1693749920],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.7.self_attn.q_norm.weight":{"data_offsets":[136915584,136916096],"dtype":"BF16","shape":[256]},"model.language_model.layers.7.self_attn.q_proj.biases":{"data_offsets":[834108320,836074400],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.7.self_attn.q_proj.scales":{"data_offsets":[2092497728,2094463808],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.7.self_attn.q_proj.weight":{"data_offsets":[747322432,778779712],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.7.self_attn.v_proj.biases":{"data_offsets":[359973696,360137536],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.7.self_attn.v_proj.scales":{"data_offsets":[136751744,136915584],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.7.self_attn.v_proj.weight":{"data_offsets":[2057393376,2060014816],"dtype":"U32","shape":[1024,640]}}"#
data_chars header3Chars header3

/-- Verbatim JSON header of `model-00005-of-00006.safetensors` (bytes 8 … 49770). -/
def header4 : String := r#"{"__metadata__":{"format":"mlx"},"model.language_model.layers.42.mlp.down_proj.scales":{"data_offsets":[1780422400,1780457216],"dtype":"F16","shape":[17408]},"model.language_model.layers.42.mlp.down_proj.weight":{"data_offsets":[1034415648,1067839008],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.42.mlp.gate_proj.scales":{"data_offsets":[1711552768,1711587584],"dtype":"F16","shape":[17408]},"model.language_model.layers.42.mlp.gate_proj.weight":{"data_offsets":[703275072,736698432],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.42.mlp.up_proj.scales":{"data_offsets":[2139887936,2139922752],"dtype":"F16","shape":[17408]},"model.language_model.layers.42.mlp.up_proj.weight":{"data_offsets":[1745893120,1779316480],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.42.post_attention_layernorm.weight":{"data_offsets":[1978467648,1978477888],"dtype":"BF16","shape":[5120]},"model.language_model.layers.43.input_layernorm.weight":{"data_offsets":[1211941760,1211952000],"dtype":"BF16","shape":[5120]},"model.language_model.layers.43.mlp.down_proj.scales":{"data_offsets":[1892018048,1892052864],"dtype":"F16","shape":[17408]},"model.language_model.layers.43.mlp.down_proj.weight":{"data_offsets":[2029294400,2062717760],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.43.mlp.gate_proj.scales":{"data_offsets":[1847951040,1847985856],"dtype":"F16","shape":[17408]},"model.language_model.layers.43.mlp.gate_proj.weight":{"data_offsets":[1666568864,1688851104],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.43.mlp.up_proj.scales":{"data_offsets":[1711751424,1711786240],"dtype":"F16","shape":[17408]},"model.language_model.layers.43.mlp.up_proj.weight":{"data_offsets":[1460510688,1493934048],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.43.post_attention_layernorm.weight":{"data_offsets":[1711786240,1711796480],"dtype":"BF16","shape":[5120]},"model.language_model.layers.43.self_attn.k_norm.weight":{"data_offsets":[1977320256,1977320768],"dtype":"BF16","shape":[256]},"model.language_model.layers.43.self_attn.k_proj.biases":{"data_offsets":[1271854048,1272017888],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.43.self_attn.k_proj.scales":{"data_offsets":[742079552,742243392],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.43.self_attn.k_proj.weight":{"data_offsets":[1845321920,1847943360],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.43.self_attn.o_proj.biases":{"data_offsets":[1978477888,1979460928],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.43.self_attn.o_proj.scales":{"data_offsets":[635367744,636350784],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.43.self_attn.o_proj.weight":{"data_offsets":[1782103296,1797831936],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.43.self_attn.q_norm.weight":{"data_offsets":[1980451648,1980452160],"dtype":"BF16","shape":[256]},"model.language_model.layers.43.self_attn.q_proj.biases":{"data_offsets":[633309504,635275584],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.43.self_attn.q_proj.scales":{"data_offsets":[1000828448,1002794528],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.43.self_attn.q_proj.weight":{"data_offsets":[2085130560,2116587840],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.43.self_attn.v_proj.biases":{"data_offsets":[1850607296,1850771136],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.43.self_attn.v_proj.scales":{"data_offsets":[1002794528,1002958368],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.43.self_attn.v_proj.weight":{"data_offsets":[1272017888,1274639328],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.44.input_layernorm.weight":{"data_offsets":[1980452160,1980462400],"dtype":"BF16","shape":[5120]},"model.language_model.layers.44.linear_attn.A_log":{"data_offsets":[1709871776,1709871872],"dtype":"BF16","shape":[48]},"model.language_model.layers.44.linear_attn.conv1d.weight":{"data_offsets":[2140906048,2140987968],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.44.linear_attn.dt_bias":{"data_offsets":[1831313408,1831313504],"dtype":"BF16","shape":[48]},"model.language_model.layers.44.linear_attn.in_proj_a.biases":{"data_offsets":[1782095616,1782103296],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.44.linear_attn.in_proj_a.scales":{"data_offsets":[1831298048,1831305728],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.44.linear_attn.in_proj_a.weight":{"data_offsets":[894912960,895035840],"dtype":"U32","shape":[48,640]},"model.language_model.layers.44.linear_attn.in_proj_b.biases":{"data_offsets":[1711796480,1711804160],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.44.linear_attn.in_proj_b.scales":{"data_offsets":[1493934048,1493941728],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.44.linear_attn.in_proj_b.weight":{"data_offsets":[868604576,868727456],"dtype":"U32","shape":[48,640]},"model.language_model.layers.44.linear_attn.in_proj_qkv.biases":{"data_offsets":[1596005536,1597643936],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.44.linear_attn.in_proj_qkv.scales":{"data_offsets":[1211960288,1213598688],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.44.linear_attn.in_proj_qkv.weight":{"data_offsets":[868727456,888388256],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.44.linear_attn.in_proj_z.biases":{"data_offsets":[1844175040,1845158080],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.44.linear_attn.in_proj_z.scales":{"data_offsets":[1779316480,1780299520],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.44.linear_attn.in_proj_z.weight":{"data_offsets":[1831313504,1843109984],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.44.linear_attn.norm.weight":{"data_offsets":[1831262976,1831263232],"dtype":"BF16","shape":[128]},"model.language_model.layers.44.linear_attn.out_proj.biases":{"data_offsets":[1688885920,1689868960],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.44.linear_attn.out_proj.scales":{"data_offsets":[1215237088,1216220128],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.44.linear_attn.out_proj.weight":{"data_offsets":[1892052864,1903849344],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.44.mlp.down_proj.scales":{"data_offsets":[1935307232,1935342048],"dtype":"F16","shape":[17408]},"model.language_model.layers.44.mlp.down_proj.weight":{"data_offsets":[1340379616,1373802976],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.44.mlp.gate_proj.scales":{"data_offsets":[800084640,800119456],"dtype":"F16","shape":[17408]},"model.language_model.layers.44.mlp.gate_proj.weight":{"data_offsets":[1863837472,1886119712],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.44.mlp.up_proj.scales":{"data_offsets":[1594949280,1594984096],"dtype":"F16","shape":[17408]},"model.language_model.layers.44.mlp.up_proj.weight":{"data_offsets":[1597643936,1619926176],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.44.post_attention_layernorm.weight":{"data_offsets":[1594994336,1595004576],"dtype":"BF16","shape":[5120]},"model.language_model.layers.45.input_layernorm.weight":{"data_offsets":[1745882880,1745893120],"dtype":"BF16","shape":[5120]},"model.language_model.layers.45.linear_attn.A_log":{"data_offsets":[1572666848,1572666944],"dtype":"BF16","shape":[48]},"model.language_model.layers.45.linear_attn.conv1d.weight":{"data_offsets":[1527365088,1527447008],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.45.linear_attn.dt_bias":{"data_offsets":[1844174944,1844175040],"dtype":"BF16","shape":[48]},"model.language_model.layers.45.linear_attn.in_proj_a.biases":{"data_offsets":[1595004576,1595012256],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.45.linear_attn.in_proj_a.scales":{"data_offsets":[2085122880,2085130560],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.45.linear_attn.in_proj_a.weight":{"data_offsets":[1459404768,1459527648],"dtype":"U32","shape":[48,640]},"model.language_model.layers.45.linear_attn.in_proj_b.biases":{"data_offsets":[1620944032,1620951712],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.45.linear_attn.in_proj_b.scales":{"data_offsets":[1436131808,1436139488],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.45.linear_attn.in_proj_b.weight":{"data_offsets":[633025344,633148224],"dtype":"U32","shape":[48,640]},"model.language_model.layers.45.linear_attn.in_proj_qkv.biases":{"data_offsets":[1375476192,1377114592],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.45.linear_attn.in_proj_qkv.scales":{"data_offsets":[1780457216,1782095616],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.45.linear_attn.in_proj_qkv.weight":{"data_offsets":[1689879200,1709540000],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.45.linear_attn.in_proj_z.biases":{"data_offsets":[1620951712,1621934752],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.45.linear_attn.in_proj_z.scales":{"data_offsets":[1595012256,1595995296],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.45.linear_attn.in_proj_z.weight":{"data_offsets":[1328583136,1340379616],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.45.linear_attn.norm.weight":{"data_offsets":[2140987968,2140988224],"dtype":"BF16","shape":[128]},"model.language_model.layers.45.linear_attn.out_proj.biases":{"data_offsets":[1325961696,1326944736],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.45.linear_attn.out_proj.scales":{"data_offsets":[1423317472,1424300512],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.45.linear_attn.out_proj.weight":{"data_offsets":[1851754176,1863550656],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.45.mlp.down_proj.scales":{"data_offsets":[1300906464,1300941280],"dtype":"F16","shape":[17408]},"model.language_model.layers.45.mlp.down_proj.weight":{"data_offsets":[1300941280,1323223520],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.45.mlp.gate_proj.scales":{"data_offsets":[1300871648,1300906464],"dtype":"F16","shape":[17408]},"model.language_model.layers.45.mlp.gate_proj.weight":{"data_offsets":[919465920,941748160],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.45.mlp.up_proj.scales":{"data_offsets":[1621969568,1622004384],"dtype":"F16","shape":[17408]},"model.language_model.layers.45.mlp.up_proj.weight":{"data_offsets":[1723600640,1745882880],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.45.post_attention_layernorm.weight":{"data_offsets":[1274647008,1274657248],"dtype":"BF16","shape":[5120]},"model.language_model.layers.46.input_layernorm.weight":{"data_offsets":[1271720928,1271731168],"dtype":"BF16","shape":[5120]},"model.language_model.layers.46.linear_attn.A_log":{"data_offsets":[1211952000,1211952096],"dtype":"BF16","shape":[48]},"model.language_model.layers.46.linear_attn.conv1d.weight":{"data_offsets":[1843109984,1843191904],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.46.linear_attn.dt_bias":{"data_offsets":[1955037664,1955037760],"dtype":"BF16","shape":[48]},"model.language_model.layers.46.linear_attn.in_proj_a.biases":{"data_offsets":[974605856,974613536],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.46.linear_attn.in_proj_a.scales":{"data_offsets":[1831305728,1831313408],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.46.linear_attn.in_proj_a.weight":{"data_offsets":[1258163168,1258286048],"dtype":"U32","shape":[48,640]},"model.language_model.layers.46.linear_attn.in_proj_b.biases":{"data_offsets":[1981445440,1981453120],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.46.linear_attn.in_proj_b.scales":{"data_offsets":[1797831936,1797839616],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.46.linear_attn.in_proj_b.weight":{"data_offsets":[1709748896,1709871776],"dtype":"U32","shape":[48,640]},"model.language_model.layers.46.linear_attn.in_proj_qkv.biases":{"data_offsets":[1210139520,1211777920],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.46.linear_attn.in_proj_qkv.scales":{"data_offsets":[1213598688,1215237088],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.46.linear_attn.in_proj_qkv.weight":{"data_offsets":[1216220128,1235880928],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.46.linear_attn.in_proj_z.biases":{"data_offsets":[1148606080,1149589120],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.46.linear_attn.in_proj_z.scales":{"data_offsets":[1977320768,1978303808],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.46.linear_attn.in_proj_z.weight":{"data_offsets":[1259924448,1271720928],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.46.linear_attn.norm.weight":{"data_offsets":[1208128128,1208128384],"dtype":"BF16","shape":[128]},"model.language_model.layers.46.linear_attn.out_proj.biases":{"data_offsets":[1194365568,1195348608],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.46.linear_attn.out_proj.scales":{"data_offsets":[1195348608,1196331648],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.46.linear_attn.out_proj.weight":{"data_offsets":[1196331648,1208128128],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.46.mlp.down_proj.scales":{"data_offsets":[1172048512,1172083328],"dtype":"F16","shape":[17408]},"model.language_model.layers.46.mlp.down_proj.weight":{"data_offsets":[1172083328,1194365568],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.46.mlp.gate_proj.scales":{"data_offsets":[1621934752,1621969568],"dtype":"F16","shape":[17408]},"model.language_model.layers.46.mlp.gate_proj.weight":{"data_offsets":[1955038016,1977320256],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.46.mlp.up_proj.scales":{"data_offsets":[1149731456,1149766272],"dtype":"F16","shape":[17408]},"model.language_model.layers.46.mlp.up_proj.weight":{"data_offsets":[1149766272,1172048512],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.46.post_attention_layernorm.weight":{"data_offsets":[1149713536,1149723776],"dtype":"BF16","shape":[5120]},"model.language_model.layers.47.input_layernorm.weight":{"data_offsets":[892975776,892986016],"dtype":"BF16","shape":[5120]},"model.language_model.layers.47.mlp.down_proj.scales":{"data_offsets":[1149589120,1149623936],"dtype":"F16","shape":[17408]},"model.language_model.layers.47.mlp.down_proj.weight":{"data_offsets":[2117570880,2139853120],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.47.mlp.gate_proj.scales":{"data_offsets":[1711510272,1711545088],"dtype":"F16","shape":[17408]},"model.language_model.layers.47.mlp.gate_proj.weight":{"data_offsets":[1572667040,1594949280],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.47.mlp.up_proj.scales":{"data_offsets":[1436096992,1436131808],"dtype":"F16","shape":[17408]},"model.language_model.layers.47.mlp.up_proj.weight":{"data_offsets":[1126323840,1148606080],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.47.post_attention_layernorm.weight":{"data_offsets":[1709738656,1709748896],"dtype":"BF16","shape":[5120]},"model.language_model.layers.47.self_attn.k_norm.weight":{"data_offsets":[1935306624,1935307136],"dtype":"BF16","shape":[256]},"model.language_model.layers.47.self_attn.k_proj.biases":{"data_offsets":[1863550656,1863714496],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.47.self_attn.k_proj.scales":{"data_offsets":[1978303808,1978467648],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.47.self_attn.k_proj.weight":{"data_offsets":[1889396512,1892017952],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.47.self_attn.o_proj.biases":{"data_offsets":[1067839008,1068822048],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.47.self_attn.o_proj.scales":{"data_offsets":[1459527648,1460510688],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.47.self_attn.o_proj.weight":{"data_offsets":[1110437408,1126166048],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.47.self_attn.q_norm.weight":{"data_offsets":[974613536,974614048],"dtype":"BF16","shape":[256]},"model.language_model.layers.47.self_attn.q_proj.biases":{"data_offsets":[917328320,919294400],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.47.self_attn.q_proj.scales":{"data_offsets":[1208173440,1210139520],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.47.self_attn.q_proj.weight":{"data_offsets":[1002958368,1034415648],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.47.self_attn.v_proj.biases":{"data_offsets":[919294400,919458240],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.47.self_attn.v_proj.scales":{"data_offsets":[941878720,942042560],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.47.self_attn.v_proj.weight":{"data_offsets":[1847985856,1850607296],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.48.input_layernorm.weight":{"data_offsets":[895035840,895046080],"dtype":"BF16","shape":[5120]},"model.language_model.layers.48.linear_attn.A_log":{"data_offsets":[893151584,893151680],"dtype":"BF16","shape":[48]},"model.language_model.layers.48.linear_attn.conv1d.weight":{"data_offsets":[800002720,800084640],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.48.linear_attn.dt_bias":{"data_offsets":[893151392,893151488],"dtype":"BF16","shape":[48]},"model.language_model.layers.48.linear_attn.in_proj_a.biases":{"data_offsets":[1149723776,1149731456],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.48.linear_attn.in_proj_a.scales":{"data_offsets":[736698432,736706112],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.48.linear_attn.in_proj_a.weight":{"data_offsets":[1271731168,1271854048],"dtype":"U32","shape":[48,640]},"model.language_model.layers.48.linear_attn.in_proj_b.biases":{"data_offsets":[892986016,892993696],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.48.linear_attn.in_proj_b.scales":{"data_offsets":[1149623936,1149631616],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.48.linear_attn.in_proj_b.weight":{"data_offsets":[892993696,893116576],"dtype":"U32","shape":[48,640]},"model.language_model.layers.48.linear_attn.in_proj_qkv.biases":{"data_offsets":[891337376,892975776],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.48.linear_attn.in_proj_qkv.scales":{"data_offsets":[1326944736,1328583136],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.48.linear_attn.in_proj_qkv.weight":{"data_offsets":[1935342048,1955002848],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.48.linear_attn.in_proj_z.biases":{"data_offsets":[888388256,889371296],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.48.linear_attn.in_proj_z.scales":{"data_offsets":[1436139488,1437122528],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.48.linear_attn.in_proj_z.weight":{"data_offsets":[2017497920,2029294400],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.48.linear_attn.norm.weight":{"data_offsets":[2140905792,2140906048],"dtype":"BF16","shape":[128]},"model.language_model.layers.48.linear_attn.out_proj.biases":{"data_offsets":[800119456,801102496],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.48.linear_attn.out_proj.scales":{"data_offsets":[973622816,974605856],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.48.linear_attn.out_proj.weight":{"data_offsets":[823384736,835181216],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.48.mlp.down_proj.scales":{"data_offsets":[799967904,800002720],"dtype":"F16","shape":[17408]},"model.language_model.layers.48.mlp.down_proj.weight":{"data_offsets":[1437122528,1459404768],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.48.mlp.gate_proj.scales":{"data_offsets":[777640608,777675424],"dtype":"F16","shape":[17408]},"model.language_model.layers.48.mlp.gate_proj.weight":{"data_offsets":[777685664,799967904],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.48.mlp.up_proj.scales":{"data_offsets":[893116576,893151392],"dtype":"F16","shape":[17408]},"model.language_model.layers.48.mlp.up_proj.weight":{"data_offsets":[1235880928,1258163168],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.48.post_attention_layernorm.weight":{"data_offsets":[1594984096,1594994336],"dtype":"BF16","shape":[5120]},"model.language_model.layers.49.input_layernorm.weight":{"data_offsets":[1595995296,1596005536],"dtype":"BF16","shape":[5120]},"model.language_model.layers.49.linear_attn.A_log":{"data_offsets":[1572666944,1572667040],"dtype":"BF16","shape":[48]},"model.language_model.layers.49.linear_attn.conv1d.weight":{"data_offsets":[1323223520,1323305440],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.49.linear_attn.dt_bias":{"data_offsets":[742251072,742251168],"dtype":"BF16","shape":[48]},"model.language_model.layers.49.linear_attn.in_proj_a.biases":{"data_offsets":[941748160,941755840],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.49.linear_attn.in_proj_a.scales":{"data_offsets":[742243392,742251072],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.49.linear_attn.in_proj_a.weight":{"data_offsets":[941755840,941878720],"dtype":"U32","shape":[48,640]},"model.language_model.layers.49.linear_attn.in_proj_b.biases":{"data_offsets":[740965952,740973632],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.49.linear_attn.in_proj_b.scales":{"data_offsets":[1980443968,1980451648],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.49.linear_attn.in_proj_b.weight":{"data_offsets":[740973632,741096512],"dtype":"U32","shape":[48,640]},"model.language_model.layers.49.linear_attn.in_proj_qkv.biases":{"data_offsets":[737689152,739327552],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.49.linear_attn.in_proj_qkv.scales":{"data_offsets":[739327552,740965952],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.49.linear_attn.in_proj_qkv.weight":{"data_offsets":[1068822048,1088482848],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.49.linear_attn.in_proj_z.biases":{"data_offsets":[736706112,737689152],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.49.linear_attn.in_proj_z.scales":{"data_offsets":[1422334432,1423317472],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.49.linear_attn.in_proj_z.weight":{"data_offsets":[1527447008,1539243488],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.49.linear_attn.norm.weight":{"data_offsets":[703240000,703240256],"dtype":"BF16","shape":[128]},"model.language_model.layers.49.linear_attn.out_proj.biases":{"data_offsets":[1980462400,1981445440],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.49.linear_attn.out_proj.scales":{"data_offsets":[1850771136,1851754176],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.49.linear_attn.out_proj.weight":{"data_offsets":[1424300512,1436096992],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.49.mlp.down_proj.scales":{"data_offsets":[658640704,658675520],"dtype":"F16","shape":[17408]},"model.language_model.layers.49.mlp.down_proj.weight":{"data_offsets":[895046080,917328320],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.49.mlp.gate_proj.scales":{"data_offsets":[1373802976,1373837792],"dtype":"F16","shape":[17408]},"model.language_model.layers.49.mlp.gate_proj.weight":{"data_offsets":[636350784,658633024],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.49.mlp.up_proj.scales":{"data_offsets":[1208138624,1208173440],"dtype":"F16","shape":[17408]},"model.language_model.layers.49.mlp.up_proj.weight":{"data_offsets":[801102496,823384736],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.49.post_attention_layernorm.weight":{"data_offsets":[777675424,777685664],"dtype":"BF16","shape":[5120]},"model.language_model.layers.50.input_layernorm.weight":{"data_offsets":[635357504,635367744],"dtype":"BF16","shape":[5120]},"model.language_model.layers.50.linear_attn.A_log":{"data_offsets":[957771200,957771296],"dtype":"BF16","shape":[48]},"model.language_model.layers.50.linear_attn.conv1d.weight":{"data_offsets":[635275584,635357504],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.50.linear_attn.dt_bias":{"data_offsets":[1126323744,1126323840],"dtype":"BF16","shape":[48]},"model.language_model.layers.50.linear_attn.in_proj_a.biases":{"data_offsets":[633163584,633171264],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.50.linear_attn.in_proj_a.scales":{"data_offsets":[633171264,633178944],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.50.linear_attn.in_proj_a.weight":{"data_offsets":[633178944,633301824],"dtype":"U32","shape":[48,640]},"model.language_model.layers.50.linear_attn.in_proj_b.biases":{"data_offsets":[633148224,633155904],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.50.linear_attn.in_proj_b.scales":{"data_offsets":[633155904,633163584],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.50.linear_attn.in_proj_b.weight":{"data_offsets":[894790080,894912960],"dtype":"U32","shape":[48,640]},"model.language_model.layers.50.linear_attn.in_proj_qkv.biases":{"data_offsets":[1373837792,1375476192],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.50.linear_attn.in_proj_qkv.scales":{"data_offsets":[631352128,632990528],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.50.linear_attn.in_proj_qkv.weight":{"data_offsets":[757979808,777640608],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.50.linear_attn.in_proj_z.biases":{"data_offsets":[629375808,630358848],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.50.linear_attn.in_proj_z.scales":{"data_offsets":[630369088,631352128],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.50.linear_attn.in_proj_z.weight":{"data_offsets":[1711804160,1723600640],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.50.linear_attn.norm.weight":{"data_offsets":[629375552,629375808],"dtype":"BF16","shape":[128]},"model.language_model.layers.50.linear_attn.out_proj.biases":{"data_offsets":[614584896,615567936],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.50.linear_attn.out_proj.scales":{"data_offsets":[616585792,617568832],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.50.linear_attn.out_proj.weight":{"data_offsets":[617568832,629365312],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.50.mlp.down_proj.scales":{"data_offsets":[1709703840,1709738656],"dtype":"F16","shape":[17408]},"model.language_model.layers.50.mlp.down_proj.weight":{"data_offsets":[581161536,614584896],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.50.mlp.gate_proj.scales":{"data_offsets":[1831263232,1831298048],"dtype":"F16","shape":[17408]},"model.language_model.layers.50.mlp.gate_proj.weight":{"data_offsets":[558879296,581161536],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.50.mlp.up_proj.scales":{"data_offsets":[632990528,633025344],"dtype":"F16","shape":[17408]},"model.language_model.layers.50.mlp.up_proj.weight":{"data_offsets":[1984074560,2017497920],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.50.post_attention_layernorm.weight":{"data_offsets":[558858816,558869056],"dtype":"BF16","shape":[5120]},"model.language_model.layers.51.input_layernorm.weight":{"data_offsets":[1208128384,1208138624],"dtype":"BF16","shape":[5120]},"model.language_model.layers.51.mlp.down_proj.scales":{"data_offsets":[1620909216,1620944032],"dtype":"F16","shape":[17408]},"model.language_model.layers.51.mlp.down_proj.weight":{"data_offsets":[1493941728,1527365088],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.51.mlp.gate_proj.scales":{"data_offsets":[536541760,536576576],"dtype":"F16","shape":[17408]},"model.language_model.layers.51.mlp.gate_proj.weight":{"data_offsets":[536576576,558858816],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.51.mlp.up_proj.scales":{"data_offsets":[1126288928,1126323744],"dtype":"F16","shape":[17408]},"model.language_model.layers.51.mlp.up_proj.weight":{"data_offsets":[503118400,536541760],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.51.post_attention_layernorm.weight":{"data_offsets":[503108160,503118400],"dtype":"BF16","shape":[5120]},"model.language_model.layers.51.self_attn.k_norm.weight":{"data_offsets":[503107648,503108160],"dtype":"BF16","shape":[256]},"model.language_model.layers.51.self_attn.k_proj.biases":{"data_offsets":[1845158080,1845321920],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.51.self_attn.k_proj.scales":{"data_offsets":[1711587584,1711751424],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.51.self_attn.k_proj.weight":{"data_offsets":[1981453120,1984074560],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.51.self_attn.o_proj.biases":{"data_offsets":[485412928,486395968],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.51.self_attn.o_proj.scales":{"data_offsets":[486395968,487379008],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.51.self_attn.o_proj.weight":{"data_offsets":[487379008,503107648],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.51.self_attn.q_norm.weight":{"data_offsets":[485404736,485405248],"dtype":"BF16","shape":[256]},"model.language_model.layers.51.self_attn.q_proj.biases":{"data_offsets":[449032256,450998336],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.51.self_attn.q_proj.scales":{"data_offsets":[451981376,453947456],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.51.self_attn.q_proj.weight":{"data_offsets":[453947456,485404736],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.51.self_attn.v_proj.biases":{"data_offsets":[446246720,446410560],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.51.self_attn.v_proj.scales":{"data_offsets":[1110273568,1110437408],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.51.self_attn.v_proj.weight":{"data_offsets":[446410560,449032000],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.52.input_layernorm.weight":{"data_offsets":[629365312,629375552],"dtype":"BF16","shape":[5120]},"model.language_model.layers.52.linear_attn.A_log":{"data_offsets":[446238944,446239040],"dtype":"BF16","shape":[48]},"model.language_model.layers.52.linear_attn.conv1d.weight":{"data_offsets":[446157024,446238944],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.52.linear_attn.dt_bias":{"data_offsets":[893151488,893151584],"dtype":"BF16","shape":[48]},"model.language_model.layers.52.linear_attn.in_proj_a.biases":{"data_offsets":[446026464,446034144],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.52.linear_attn.in_proj_a.scales":{"data_offsets":[1274639328,1274647008],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.52.linear_attn.in_proj_a.weight":{"data_offsets":[446034144,446157024],"dtype":"U32","shape":[48,640]},"model.language_model.layers.52.linear_attn.in_proj_b.biases":{"data_offsets":[401454304,401461984],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.52.linear_attn.in_proj_b.scales":{"data_offsets":[1847943360,1847951040],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.52.linear_attn.in_proj_b.weight":{"data_offsets":[2085000000,2085122880],"dtype":"U32","shape":[48,640]},"model.language_model.layers.52.linear_attn.in_proj_qkv.biases":{"data_offsets":[380155104,381793504],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.52.linear_attn.in_proj_qkv.scales":{"data_offsets":[1887758112,1889396512],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.52.linear_attn.in_proj_qkv.weight":{"data_offsets":[381793504,401454304],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.52.linear_attn.in_proj_z.biases":{"data_offsets":[450998336,451981376],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.52.linear_attn.in_proj_z.scales":{"data_offsets":[379172064,380155104],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.52.linear_attn.in_proj_z.weight":{"data_offsets":[1410537952,1422334432],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.52.linear_attn.norm.weight":{"data_offsets":[1955037760,1955038016],"dtype":"BF16","shape":[128]},"model.language_model.layers.52.linear_attn.out_proj.biases":{"data_offsets":[365409504,366392544],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.52.linear_attn.out_proj.scales":{"data_offsets":[1324978656,1325961696],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.52.linear_attn.out_proj.weight":{"data_offsets":[367375584,379172064],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.52.mlp.down_proj.scales":{"data_offsets":[1955002848,1955037664],"dtype":"F16","shape":[17408]},"model.language_model.layers.52.mlp.down_proj.weight":{"data_offsets":[835181216,868604576],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.52.mlp.gate_proj.scales":{"data_offsets":[365374688,365409504],"dtype":"F16","shape":[17408]},"model.language_model.layers.52.mlp.gate_proj.weight":{"data_offsets":[1377114592,1410537952],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.52.mlp.up_proj.scales":{"data_offsets":[1688851104,1688885920],"dtype":"F16","shape":[17408]},"model.language_model.layers.52.mlp.up_proj.weight":{"data_offsets":[1797839616,1831262976],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.52.post_attention_layernorm.weight":{"data_offsets":[365241568,365251808],"dtype":"BF16","shape":[5120]},"model.language_model.layers.53.input_layernorm.weight":{"data_offsets":[363592928,363603168],"dtype":"BF16","shape":[5120]},"model.language_model.layers.53.linear_attn.A_log":{"data_offsets":[363585152,363585248],"dtype":"BF16","shape":[48]},"model.language_model.layers.53.linear_attn.conv1d.weight":{"data_offsets":[363503232,363585152],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.53.linear_attn.dt_bias":{"data_offsets":[363503136,363503232],"dtype":"BF16","shape":[48]},"model.language_model.layers.53.linear_attn.in_proj_a.biases":{"data_offsets":[919458240,919465920],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.53.linear_attn.in_proj_a.scales":{"data_offsets":[633301824,633309504],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.53.linear_attn.in_proj_a.weight":{"data_offsets":[1780299520,1780422400],"dtype":"U32","shape":[48,640]},"model.language_model.layers.53.linear_attn.in_proj_b.biases":{"data_offsets":[1711545088,1711552768],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.53.linear_attn.in_proj_b.scales":{"data_offsets":[363372576,363380256],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.53.linear_attn.in_proj_b.weight":{"data_offsets":[363380256,363503136],"dtype":"U32","shape":[48,640]},"model.language_model.layers.53.linear_attn.in_proj_qkv.biases":{"data_offsets":[893151680,894790080],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.53.linear_attn.in_proj_qkv.scales":{"data_offsets":[361734176,363372576],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.53.linear_attn.in_proj_qkv.weight":{"data_offsets":[1090612768,1110273568],"dtype":"U32","shape":[10240,480]},"model.language_model.layers.53.linear_attn.in_proj_z.biases":{"data_offsets":[344967200,345950240],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.53.linear_attn.in_proj_z.scales":{"data_offsets":[1843191904,1844174944],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.53.linear_attn.in_proj_z.weight":{"data_offsets":[345960480,361689120],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.53.linear_attn.norm.weight":{"data_offsets":[449032000,449032256],"dtype":"BF16","shape":[128]},"model.language_model.layers.53.linear_attn.out_proj.biases":{"data_offsets":[366392544,367375584],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.53.linear_attn.out_proj.scales":{"data_offsets":[741096512,742079552],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.53.linear_attn.out_proj.weight":{"data_offsets":[332187680,343984160],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.53.mlp.down_proj.scales":{"data_offsets":[298721568,298756384],"dtype":"F16","shape":[17408]},"model.language_model.layers.53.mlp.down_proj.weight":{"data_offsets":[298764320,332187680],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.53.mlp.gate_proj.scales":{"data_offsets":[298686752,298721568],"dtype":"F16","shape":[17408]},"model.language_model.layers.53.mlp.gate_proj.weight":{"data_offsets":[2062717760,2085000000],"dtype":"U32","shape":[17408,320]},"model.language_model.layers.53.mlp.up_proj.scales":{"data_offsets":[361699360,361734176],"dtype":"F16","shape":[17408]},"model.language_model.layers.53.mlp.up_proj.weight":{"data_offsets":[265263392,298686752],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.53.post_attention_layernorm.weight":{"data_offsets":[1689868960,1689879200],"dtype":"BF16","shape":[5120]},"model.language_model.layers.54.input_layernorm.weight":{"data_offsets":[345950240,345960480],"dtype":"BF16","shape":[5120]},"model.language_model.layers.54.linear_attn.A_log":{"data_offsets":[265263296,265263392],"dtype":"BF16","shape":[48]},"model.language_model.layers.54.linear_attn.conv1d.weight":{"data_offsets":[265181120,265263040],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.54.linear_attn.dt_bias":{"data_offsets":[1863837376,1863837472],"dtype":"BF16","shape":[48]},"model.language_model.layers.54.linear_attn.in_proj_a.biases":{"data_offsets":[264182720,264190400],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.54.linear_attn.in_proj_a.scales":{"data_offsets":[265173440,265181120],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.54.linear_attn.in_proj_a.weight":{"data_offsets":[1126166048,1126288928],"dtype":"U32","shape":[48,640]},"model.language_model.layers.54.linear_attn.in_proj_b.biases":{"data_offsets":[264052160,264059840],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.54.linear_attn.in_proj_b.scales":{"data_offsets":[658633024,658640704],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.54.linear_attn.in_proj_b.weight":{"data_offsets":[264059840,264182720],"dtype":"U32","shape":[48,640]},"model.language_model.layers.54.linear_attn.in_proj_qkv.biases":{"data_offsets":[1886119712,1887758112],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.54.linear_attn.in_proj_qkv.scales":{"data_offsets":[259782080,261420480],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.54.linear_attn.in_proj_qkv.weight":{"data_offsets":[1274657248,1300871648],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.54.linear_attn.in_proj_z.biases":{"data_offsets":[615602752,616585792],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.54.linear_attn.in_proj_z.scales":{"data_offsets":[343984160,344967200],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.54.linear_attn.in_proj_z.weight":{"data_offsets":[957894176,973622816],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.54.linear_attn.norm.weight":{"data_offsets":[265263040,265263296],"dtype":"BF16","shape":[128]},"model.language_model.layers.54.linear_attn.out_proj.biases":{"data_offsets":[264190400,265173440],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.54.linear_attn.out_proj.scales":{"data_offsets":[1619926176,1620909216],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.54.linear_attn.out_proj.weight":{"data_offsets":[942042560,957771200],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.54.mlp.down_proj.scales":{"data_offsets":[1324943840,1324978656],"dtype":"F16","shape":[17408]},"model.language_model.layers.54.mlp.down_proj.weight":{"data_offsets":[658675520,703240000],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.54.mlp.gate_proj.scales":{"data_offsets":[226323904,226358720],"dtype":"F16","shape":[17408]},"model.language_model.layers.54.mlp.gate_proj.weight":{"data_offsets":[226358720,259782080],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.54.mlp.up_proj.scales":{"data_offsets":[615567936,615602752],"dtype":"F16","shape":[17408]},"model.language_model.layers.54.mlp.up_proj.weight":{"data_offsets":[1539243488,1572666848],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.54.post_attention_layernorm.weight":{"data_offsets":[264041920,264052160],"dtype":"BF16","shape":[5120]},"model.language_model.layers.55.input_layernorm.weight":{"data_offsets":[226313664,226323904],"dtype":"BF16","shape":[5120]},"model.language_model.layers.55.mlp.down_proj.scales":{"data_offsets":[226278848,226313664],"dtype":"F16","shape":[17408]},"model.language_model.layers.55.mlp.down_proj.weight":{"data_offsets":[401461984,446026464],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.55.mlp.gate_proj.scales":{"data_offsets":[192820672,192855488],"dtype":"F16","shape":[17408]},"model.language_model.layers.55.mlp.gate_proj.weight":{"data_offsets":[192855488,226278848],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.55.mlp.up_proj.scales":{"data_offsets":[703240256,703275072],"dtype":"F16","shape":[17408]},"model.language_model.layers.55.mlp.up_proj.weight":{"data_offsets":[159397312,192820672],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.55.post_attention_layernorm.weight":{"data_offsets":[361689120,361699360],"dtype":"BF16","shape":[5120]},"model.language_model.layers.55.self_attn.k_norm.weight":{"data_offsets":[1211959776,1211960288],"dtype":"BF16","shape":[256]},"model.language_model.layers.55.self_attn.k_proj.biases":{"data_offsets":[1211777920,1211941760],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.55.self_attn.k_proj.scales":{"data_offsets":[158250432,158414272],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.55.self_attn.k_proj.weight":{"data_offsets":[261420480,264041920],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.55.self_attn.o_proj.biases":{"data_offsets":[158414272,159397312],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.55.self_attn.o_proj.scales":{"data_offsets":[141538752,142521792],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.55.self_attn.o_proj.weight":{"data_offsets":[142521792,158250432],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.55.self_attn.q_norm.weight":{"data_offsets":[141538240,141538752],"dtype":"BF16","shape":[256]},"model.language_model.layers.55.self_attn.q_proj.biases":{"data_offsets":[889371296,891337376],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.55.self_attn.q_proj.scales":{"data_offsets":[1088646688,1090612768],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.55.self_attn.q_proj.weight":{"data_offsets":[1903849344,1935306624],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.55.self_attn.v_proj.biases":{"data_offsets":[1709540000,1709703840],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.55.self_attn.v_proj.scales":{"data_offsets":[1088482848,1088646688],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.55.self_attn.v_proj.weight":{"data_offsets":[138916800,141538240],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.56.input_layernorm.weight":{"data_offsets":[630358848,630369088],"dtype":"BF16","shape":[5120]},"model.language_model.layers.56.linear_attn.A_log":{"data_offsets":[138916704,138916800],"dtype":"BF16","shape":[48]},"model.language_model.layers.56.linear_attn.conv1d.weight":{"data_offsets":[1149631616,1149713536],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.56.linear_attn.dt_bias":{"data_offsets":[138916608,138916704],"dtype":"BF16","shape":[48]},"model.language_model.layers.56.linear_attn.in_proj_a.biases":{"data_offsets":[138901248,138908928],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.56.linear_attn.in_proj_a.scales":{"data_offsets":[138908928,138916608],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.56.linear_attn.in_proj_a.weight":{"data_offsets":[1863714496,1863837376],"dtype":"U32","shape":[48,640]},"model.language_model.layers.56.linear_attn.in_proj_b.biases":{"data_offsets":[363585248,363592928],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.56.linear_attn.in_proj_b.scales":{"data_offsets":[446239040,446246720],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.56.linear_attn.in_proj_b.weight":{"data_offsets":[365251808,365374688],"dtype":"U32","shape":[48,640]},"model.language_model.layers.56.linear_attn.in_proj_qkv.biases":{"data_offsets":[1323305440,1324943840],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.56.linear_attn.in_proj_qkv.scales":{"data_offsets":[1258286048,1259924448],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.56.linear_attn.in_proj_qkv.weight":{"data_offsets":[112686848,138901248],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.56.linear_attn.in_proj_z.biases":{"data_offsets":[2139922752,2140905792],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.56.linear_attn.in_proj_z.scales":{"data_offsets":[95975168,96958208],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.56.linear_attn.in_proj_z.weight":{"data_offsets":[96958208,112686848],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.56.linear_attn.norm.weight":{"data_offsets":[95974912,95975168],"dtype":"BF16","shape":[128]},"model.language_model.layers.56.linear_attn.out_proj.biases":{"data_offsets":[78280192,79263232],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.56.linear_attn.out_proj.scales":{"data_offsets":[79263232,80246272],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.56.linear_attn.out_proj.weight":{"data_offsets":[80246272,95974912],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.56.mlp.down_proj.scales":{"data_offsets":[78245376,78280192],"dtype":"F16","shape":[17408]},"model.language_model.layers.56.mlp.down_proj.weight":{"data_offsets":[1622004384,1666568864],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.56.mlp.gate_proj.scales":{"data_offsets":[2139853120,2139887936],"dtype":"F16","shape":[17408]},"model.language_model.layers.56.mlp.gate_proj.weight":{"data_offsets":[33680896,78245376],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.56.mlp.up_proj.scales":{"data_offsets":[222720,257536],"dtype":"F16","shape":[17408]},"model.language_model.layers.56.mlp.up_proj.weight":{"data_offsets":[257536,33680896],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.56.post_attention_layernorm.weight":{"data_offsets":[212480,222720],"dtype":"BF16","shape":[5120]},"model.language_model.layers.57.input_layernorm.weight":{"data_offsets":[558869056,558879296],"dtype":"BF16","shape":[5120]},"model.language_model.layers.57.linear_attn.A_log":{"data_offsets":[1935307136,1935307232],"dtype":"BF16","shape":[48]},"model.language_model.layers.57.linear_attn.conv1d.weight":{"data_offsets":[130560,212480],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.57.linear_attn.dt_bias":{"data_offsets":[1892017952,1892018048],"dtype":"BF16","shape":[48]},"model.language_model.layers.57.linear_attn.in_proj_a.biases":{"data_offsets":[298756640,298764320],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.57.linear_attn.in_proj_a.scales":{"data_offsets":[485405248,485412928],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.57.linear_attn.in_proj_a.weight":{"data_offsets":[7680,130560],"dtype":"U32","shape":[48,640]},"model.language_model.layers.57.linear_attn.in_proj_b.biases":{"data_offsets":[1211952096,1211959776],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.57.linear_attn.in_proj_b.scales":{"data_offsets":[0,7680],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.57.linear_attn.in_proj_b.weight":{"data_offsets":[957771296,957894176],"dtype":"U32","shape":[48,640]},"model.language_model.layers.57.linear_attn.in_proj_qkv.biases":{"data_offsets":[363603168,365241568],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.57.linear_attn.in_proj_qkv.scales":{"data_offsets":[1709871872,1711510272],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.57.linear_attn.in_proj_qkv.weight":{"data_offsets":[974614048,1000828448],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.57.linear_attn.in_proj_z.biases":{"data_offsets":[1979460928,1980443968],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.57.linear_attn.in_proj_z.scales":{"data_offsets":[2116587840,2117570880],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.57.linear_attn.in_proj_z.weight":{"data_offsets":[742251168,757979808],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.57.linear_attn.norm.weight":{"data_offsets":[298756384,298756640],"dtype":"BF16","shape":[128]}}"#
data_chars header4Chars header4

/-- Verbatim JSON header of `model-00006-of-00006.safetensors` (bytes 8 … 21089). -/
def header5 : String := r#"{"__metadata__":{"format":"mlx"},"model.language_model.layers.57.linear_attn.out_proj.biases":{"data_offsets":[1148501760,1149484800],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.57.linear_attn.out_proj.scales":{"data_offsets":[1065813056,1066796096],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.57.linear_attn.out_proj.weight":{"data_offsets":[1106513664,1122242304],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.57.mlp.down_proj.scales":{"data_offsets":[1148466944,1148501760],"dtype":"F16","shape":[17408]},"model.language_model.layers.57.mlp.down_proj.weight":{"data_offsets":[960627776,1005192256],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.57.mlp.gate_proj.scales":{"data_offsets":[1150467840,1150502656],"dtype":"F16","shape":[17408]},"model.language_model.layers.57.mlp.gate_proj.weight":{"data_offsets":[1150502656,1195067136],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.57.mlp.up_proj.scales":{"data_offsets":[877276480,877311296],"dtype":"F16","shape":[17408]},"model.language_model.layers.57.mlp.up_proj.weight":{"data_offsets":[498948480,543512960],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.57.post_attention_layernorm.weight":{"data_offsets":[1068777632,1068787872],"dtype":"BF16","shape":[5120]},"model.language_model.layers.58.input_layernorm.weight":{"data_offsets":[679174880,679185120],"dtype":"BF16","shape":[5120]},"model.language_model.layers.58.linear_attn.A_log":{"data_offsets":[723857120,723857216],"dtype":"BF16","shape":[48]},"model.language_model.layers.58.linear_attn.conv1d.weight":{"data_offsets":[679185120,679267040],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.58.linear_attn.dt_bias":{"data_offsets":[1070024352,1070024448],"dtype":"BF16","shape":[48]},"model.language_model.layers.58.linear_attn.in_proj_a.biases":{"data_offsets":[1068769856,1068777536],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.58.linear_attn.in_proj_a.scales":{"data_offsets":[1069893792,1069901472],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.58.linear_attn.in_proj_a.weight":{"data_offsets":[1069901472,1070024352],"dtype":"U32","shape":[48,640]},"model.language_model.layers.58.linear_attn.in_proj_b.biases":{"data_offsets":[723849440,723857120],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.58.linear_attn.in_proj_b.scales":{"data_offsets":[543512960,543520640],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.58.linear_attn.in_proj_b.weight":{"data_offsets":[1068787872,1068910752],"dtype":"U32","shape":[48,640]},"model.language_model.layers.58.linear_attn.in_proj_qkv.biases":{"data_offsets":[1006175296,1007813696],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.58.linear_attn.in_proj_qkv.scales":{"data_offsets":[1064174656,1065813056],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.58.linear_attn.in_proj_qkv.weight":{"data_offsets":[1122252544,1148466944],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.58.linear_attn.in_proj_z.biases":{"data_offsets":[1072107264,1073090304],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.58.linear_attn.in_proj_z.scales":{"data_offsets":[959637056,960620096],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.58.linear_attn.in_proj_z.weight":{"data_offsets":[407993632,419790112],"dtype":"U32","shape":[6144,480]},"model.language_model.layers.58.linear_attn.norm.weight":{"data_offsets":[957990720,957990976],"dtype":"BF16","shape":[128]},"model.language_model.layers.58.linear_attn.out_proj.biases":{"data_offsets":[1067786816,1068769856],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.58.linear_attn.out_proj.scales":{"data_offsets":[1005192256,1006175296],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.58.linear_attn.out_proj.weight":{"data_offsets":[1007813696,1019610176],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.58.mlp.down_proj.scales":{"data_offsets":[832505664,832540480],"dtype":"F16","shape":[17408]},"model.language_model.layers.58.mlp.down_proj.weight":{"data_offsets":[832712000,877276480],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.58.mlp.gate_proj.scales":{"data_offsets":[483010848,483045664],"dtype":"F16","shape":[17408]},"model.language_model.layers.58.mlp.gate_proj.weight":{"data_offsets":[723926848,768491328],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.58.mlp.up_proj.scales":{"data_offsets":[911390528,911425344],"dtype":"F16","shape":[17408]},"model.language_model.layers.58.mlp.up_proj.weight":{"data_offsets":[1019610176,1064174656],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.58.post_attention_layernorm.weight":{"data_offsets":[1122242304,1122252544],"dtype":"BF16","shape":[5120]},"model.language_model.layers.59.input_layernorm.weight":{"data_offsets":[679267040,679277280],"dtype":"BF16","shape":[5120]},"model.language_model.layers.59.mlp.down_proj.scales":{"data_offsets":[1070024448,1070059264],"dtype":"F16","shape":[17408]},"model.language_model.layers.59.mlp.down_proj.weight":{"data_offsets":[634609888,679174368],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.59.mlp.gate_proj.scales":{"data_offsets":[634575072,634609888],"dtype":"F16","shape":[17408]},"model.language_model.layers.59.mlp.gate_proj.weight":{"data_offsets":[1239631616,1284196096],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.59.mlp.up_proj.scales":{"data_offsets":[723857216,723892032],"dtype":"F16","shape":[17408]},"model.language_model.layers.59.mlp.up_proj.weight":{"data_offsets":[590010592,634575072],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.59.post_attention_layernorm.weight":{"data_offsets":[483045664,483055904],"dtype":"BF16","shape":[5120]},"model.language_model.layers.59.self_attn.k_norm.weight":{"data_offsets":[679174368,679174880],"dtype":"BF16","shape":[256]},"model.language_model.layers.59.self_attn.k_proj.biases":{"data_offsets":[498784544,498948384],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.59.self_attn.k_proj.scales":{"data_offsets":[589846496,590010336],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.59.self_attn.k_proj.weight":{"data_offsets":[786876224,789497664],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.59.self_attn.o_proj.biases":{"data_offsets":[481044768,482027808],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.59.self_attn.o_proj.scales":{"data_offsets":[482027808,483010848],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.59.self_attn.o_proj.weight":{"data_offsets":[483055904,498784544],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.59.self_attn.q_norm.weight":{"data_offsets":[911390016,911390528],"dtype":"BF16","shape":[256]},"model.language_model.layers.59.self_attn.q_proj.biases":{"data_offsets":[956024640,957990720],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.59.self_attn.q_proj.scales":{"data_offsets":[479078688,481044768],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.59.self_attn.q_proj.weight":{"data_offsets":[877311296,908768576],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.59.self_attn.v_proj.biases":{"data_offsets":[478610208,478774048],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.59.self_attn.v_proj.scales":{"data_offsets":[478914848,479078688],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.59.self_attn.v_proj.weight":{"data_offsets":[768491328,771112768],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.60.input_layernorm.weight":{"data_offsets":[363384096,363394336],"dtype":"BF16","shape":[5120]},"model.language_model.layers.60.linear_attn.A_log":{"data_offsets":[1068777536,1068777632],"dtype":"BF16","shape":[48]},"model.language_model.layers.60.linear_attn.conv1d.weight":{"data_offsets":[1072025344,1072107264],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.60.linear_attn.dt_bias":{"data_offsets":[543520640,543520736],"dtype":"BF16","shape":[48]},"model.language_model.layers.60.linear_attn.in_proj_a.biases":{"data_offsets":[957990976,957998656],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.60.linear_attn.in_proj_a.scales":{"data_offsets":[832704320,832712000],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.60.linear_attn.in_proj_a.weight":{"data_offsets":[543520736,543643616],"dtype":"U32","shape":[48,640]},"model.language_model.layers.60.linear_attn.in_proj_b.biases":{"data_offsets":[1066796096,1066803776],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.60.linear_attn.in_proj_b.scales":{"data_offsets":[723841760,723849440],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.60.linear_attn.in_proj_b.weight":{"data_offsets":[478487328,478610208],"dtype":"U32","shape":[48,640]},"model.language_model.layers.60.linear_attn.in_proj_qkv.biases":{"data_offsets":[957998656,959637056],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.60.linear_attn.in_proj_qkv.scales":{"data_offsets":[909751616,911390016],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.60.linear_attn.in_proj_qkv.weight":{"data_offsets":[434570528,460784928],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.60.linear_attn.in_proj_z.biases":{"data_offsets":[1071042304,1072025344],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.60.linear_attn.in_proj_z.scales":{"data_offsets":[1066803776,1067786816],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.60.linear_attn.in_proj_z.weight":{"data_offsets":[462758688,478487328],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.60.linear_attn.norm.weight":{"data_offsets":[590010336,590010592],"dtype":"BF16","shape":[128]},"model.language_model.layers.60.linear_attn.out_proj.biases":{"data_offsets":[419824928,420807968],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.60.linear_attn.out_proj.scales":{"data_offsets":[420807968,421791008],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.60.linear_attn.out_proj.weight":{"data_offsets":[421791008,433587488],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.60.mlp.down_proj.scales":{"data_offsets":[419790112,419824928],"dtype":"F16","shape":[17408]},"model.language_model.layers.60.mlp.down_proj.weight":{"data_offsets":[911460160,956024640],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.60.mlp.gate_proj.scales":{"data_offsets":[911425344,911460160],"dtype":"F16","shape":[17408]},"model.language_model.layers.60.mlp.gate_proj.weight":{"data_offsets":[363429152,407993632],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.60.mlp.up_proj.scales":{"data_offsets":[363394336,363429152],"dtype":"F16","shape":[17408]},"model.language_model.layers.60.mlp.up_proj.weight":{"data_offsets":[543643616,588208096],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.60.post_attention_layernorm.weight":{"data_offsets":[478904608,478914848],"dtype":"BF16","shape":[5120]},"model.language_model.layers.61.input_layernorm.weight":{"data_offsets":[363339040,363349280],"dtype":"BF16","shape":[5120]},"model.language_model.layers.61.linear_attn.A_log":{"data_offsets":[498948384,498948480],"dtype":"BF16","shape":[48]},"model.language_model.layers.61.linear_attn.conv1d.weight":{"data_offsets":[805226304,805308224],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.61.linear_attn.dt_bias":{"data_offsets":[363338944,363339040],"dtype":"BF16","shape":[48]},"model.language_model.layers.61.linear_attn.in_proj_a.biases":{"data_offsets":[960620096,960627776],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.61.linear_attn.in_proj_a.scales":{"data_offsets":[363208384,363216064],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.61.linear_attn.in_proj_a.weight":{"data_offsets":[363216064,363338944],"dtype":"U32","shape":[48,640]},"model.language_model.layers.61.linear_attn.in_proj_b.biases":{"data_offsets":[363192512,363200192],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.61.linear_attn.in_proj_b.scales":{"data_offsets":[363200192,363207872],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.61.linear_attn.in_proj_b.weight":{"data_offsets":[478781728,478904608],"dtype":"U32","shape":[48,640]},"model.language_model.layers.61.linear_attn.in_proj_qkv.biases":{"data_offsets":[588208096,589846496],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.61.linear_attn.in_proj_qkv.scales":{"data_offsets":[361554112,363192512],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.61.linear_attn.in_proj_qkv.weight":{"data_offsets":[806291264,832505664],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.61.linear_attn.in_proj_z.biases":{"data_offsets":[433587488,434570528],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.61.linear_attn.in_proj_z.scales":{"data_offsets":[1068910752,1069893792],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.61.linear_attn.in_proj_z.weight":{"data_offsets":[771147584,786876224],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.61.linear_attn.norm.weight":{"data_offsets":[347135936,347136192],"dtype":"BF16","shape":[128]},"model.language_model.layers.61.linear_attn.out_proj.biases":{"data_offsets":[1070059264,1071042304],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.61.linear_attn.out_proj.scales":{"data_offsets":[908768576,909751616],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.61.linear_attn.out_proj.weight":{"data_offsets":[331397056,347125696],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.61.mlp.down_proj.scales":{"data_offsets":[363349280,363384096],"dtype":"F16","shape":[17408]},"model.language_model.layers.61.mlp.down_proj.weight":{"data_offsets":[286832576,331397056],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.61.mlp.gate_proj.scales":{"data_offsets":[242233184,242268000],"dtype":"F16","shape":[17408]},"model.language_model.layers.61.mlp.gate_proj.weight":{"data_offsets":[242268000,286832480],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.61.mlp.up_proj.scales":{"data_offsets":[197626208,197661024],"dtype":"F16","shape":[17408]},"model.language_model.layers.61.mlp.up_proj.weight":{"data_offsets":[197668704,242233184],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.61.post_attention_layernorm.weight":{"data_offsets":[197615968,197626208],"dtype":"BF16","shape":[5120]},"model.language_model.layers.62.input_layernorm.weight":{"data_offsets":[197605728,197615968],"dtype":"BF16","shape":[5120]},"model.language_model.layers.62.linear_attn.A_log":{"data_offsets":[286832480,286832576],"dtype":"BF16","shape":[48]},"model.language_model.layers.62.linear_attn.conv1d.weight":{"data_offsets":[197523808,197605728],"dtype":"BF16","shape":[10240,1,4]},"model.language_model.layers.62.linear_attn.dt_bias":{"data_offsets":[197523712,197523808],"dtype":"BF16","shape":[48]},"model.language_model.layers.62.linear_attn.in_proj_a.biases":{"data_offsets":[462751008,462758688],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.62.linear_attn.in_proj_a.scales":{"data_offsets":[478774048,478781728],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.62.linear_attn.in_proj_a.weight":{"data_offsets":[195434752,195557632],"dtype":"U32","shape":[48,640]},"model.language_model.layers.62.linear_attn.in_proj_b.biases":{"data_offsets":[197661024,197668704],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.62.linear_attn.in_proj_b.scales":{"data_offsets":[195304192,195311872],"dtype":"BF16","shape":[48,80]},"model.language_model.layers.62.linear_attn.in_proj_b.weight":{"data_offsets":[195311872,195434752],"dtype":"U32","shape":[48,640]},"model.language_model.layers.62.linear_attn.in_proj_qkv.biases":{"data_offsets":[165649152,167287552],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.62.linear_attn.in_proj_qkv.scales":{"data_offsets":[167287552,168925952],"dtype":"BF16","shape":[10240,80]},"model.language_model.layers.62.linear_attn.in_proj_qkv.weight":{"data_offsets":[169089792,195304192],"dtype":"U32","shape":[10240,640]},"model.language_model.layers.62.linear_attn.in_proj_z.biases":{"data_offsets":[461767968,462751008],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.62.linear_attn.in_proj_z.scales":{"data_offsets":[164666112,165649152],"dtype":"BF16","shape":[6144,80]},"model.language_model.layers.62.linear_attn.in_proj_z.weight":{"data_offsets":[789497664,805226304],"dtype":"U32","shape":[6144,640]},"model.language_model.layers.62.linear_attn.norm.weight":{"data_offsets":[164665856,164666112],"dtype":"BF16","shape":[128]},"model.language_model.layers.62.linear_attn.out_proj.biases":{"data_offsets":[805308224,806291264],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.62.linear_attn.out_proj.scales":{"data_offsets":[1149484800,1150467840],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.62.linear_attn.out_proj.weight":{"data_offsets":[349757632,361554112],"dtype":"U32","shape":[5120,576]},"model.language_model.layers.62.mlp.down_proj.scales":{"data_offsets":[723892032,723926848],"dtype":"F16","shape":[17408]},"model.language_model.layers.62.mlp.down_proj.weight":{"data_offsets":[131242496,164665856],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.62.mlp.gate_proj.scales":{"data_offsets":[131207680,131242496],"dtype":"F16","shape":[17408]},"model.language_model.layers.62.mlp.gate_proj.weight":{"data_offsets":[1073090304,1106513664],"dtype":"U32","shape":[17408,480]},"model.language_model.layers.62.mlp.up_proj.scales":{"data_offsets":[771112768,771147584],"dtype":"F16","shape":[17408]},"model.language_model.layers.62.mlp.up_proj.weight":{"data_offsets":[679277280,723841760],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.62.post_attention_layernorm.weight":{"data_offsets":[131197440,131207680],"dtype":"BF16","shape":[5120]},"model.language_model.layers.63.input_layernorm.weight":{"data_offsets":[131187200,131197440],"dtype":"BF16","shape":[5120]},"model.language_model.layers.63.mlp.down_proj.scales":{"data_offsets":[97565184,97600000],"dtype":"F16","shape":[17408]},"model.language_model.layers.63.mlp.down_proj.weight":{"data_offsets":[97600000,131023360],"dtype":"U32","shape":[10,17408,48]},"model.language_model.layers.63.mlp.gate_proj.scales":{"data_offsets":[97530368,97565184],"dtype":"F16","shape":[17408]},"model.language_model.layers.63.mlp.gate_proj.weight":{"data_offsets":[1195067136,1239631616],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.63.mlp.up_proj.scales":{"data_offsets":[52931072,52965888],"dtype":"F16","shape":[17408]},"model.language_model.layers.63.mlp.up_proj.weight":{"data_offsets":[52965888,97530368],"dtype":"U32","shape":[17408,640]},"model.language_model.layers.63.post_attention_layernorm.weight":{"data_offsets":[52920832,52931072],"dtype":"BF16","shape":[5120]},"model.language_model.layers.63.self_attn.k_norm.weight":{"data_offsets":[52920320,52920832],"dtype":"BF16","shape":[256]},"model.language_model.layers.63.self_attn.k_proj.biases":{"data_offsets":[168925952,169089792],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.63.self_attn.k_proj.scales":{"data_offsets":[832540480,832704320],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.63.self_attn.k_proj.weight":{"data_offsets":[50298880,52920320],"dtype":"U32","shape":[1024,640]},"model.language_model.layers.63.self_attn.o_proj.biases":{"data_offsets":[460784928,461767968],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.63.self_attn.o_proj.scales":{"data_offsets":[33587200,34570240],"dtype":"BF16","shape":[5120,96]},"model.language_model.layers.63.self_attn.o_proj.weight":{"data_offsets":[34570240,50298880],"dtype":"U32","shape":[5120,768]},"model.language_model.layers.63.self_attn.q_norm.weight":{"data_offsets":[363207872,363208384],"dtype":"BF16","shape":[256]},"model.language_model.layers.63.self_attn.q_proj.biases":{"data_offsets":[163840,2129920],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.63.self_attn.q_proj.scales":{"data_offsets":[195557632,197523712],"dtype":"BF16","shape":[12288,80]},"model.language_model.layers.63.self_attn.q_proj.weight":{"data_offsets":[2129920,33587200],"dtype":"U32","shape":[12288,640]},"model.language_model.layers.63.self_attn.v_proj.biases":{"data_offsets":[0,163840],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.63.self_attn.v_proj.scales":{"data_offsets":[131023360,131187200],"dtype":"BF16","shape":[1024,80]},"model.language_model.layers.63.self_attn.v_proj.weight":{"data_offsets":[347136192,349757632],"dtype":"U32","shape":[1024,640]},"model.language_model.norm.weight":{"data_offsets":[347125696,347135936],"dtype":"BF16","shape":[5120]}}"#
data_chars header5Chars header5

/-- Every file of the model directory (relative path, size in bytes). -/
def listing : List (List Char × Nat) :=
  [(chars!".gitattributes", 1625),
   (chars!"LICENSE", 11544),
   (chars!"QUANTIZATION.md", 3242),
   (chars!"README.md", 5165),
   (chars!"chat_template.jinja", 8952),
   (chars!"config.json", 256784),
   (chars!"eval/README.md", 4226),
   (chars!"eval/gpqa-diamond.json", 3658),
   (chars!"eval/gsm8k-platinum.json", 9033),
   (chars!"eval/ifeval.json", 6321),
   (chars!"eval/performance.csv", 4037),
   (chars!"eval/performance.json", 11236),
   (chars!"eval/summary.json", 2768),
   (chars!"generation_config.json", 202),
   (chars!"merges.txt", 3353259),
   (chars!"model-00001-of-00006.safetensors", 2135170504),
   (chars!"model-00002-of-00006.safetensors", 2125783722),
   (chars!"model-00003-of-00006.safetensors", 2144032162),
   (chars!"model-00004-of-00006.safetensors", 2134686008),
   (chars!"model-00005-of-00006.safetensors", 2141037994),
   (chars!"model-00006-of-00006.safetensors", 1284217185),
   (chars!"model.safetensors.index.json", 193811),
   (chars!"mtp/LICENSE", 11544),
   (chars!"mtp/README.md", 1781),
   (chars!"mtp/config.json", 4394),
   (chars!"mtp/draft_vocab.json", 382924),
   (chars!"mtp/model.safetensors", 238934105),
   (chars!"mtp/optiq_metadata.json", 154),
   (chars!"mtp/tokenizer.json", 12809320),
   (chars!"mtp/tokenizer_config.json", 17928),
   (chars!"mtp/vocab.json", 6722759),
   (chars!"optiq_metadata.json", 11668),
   (chars!"preprocessor_config.json", 390),
   (chars!"tokenizer.json", 12809320),
   (chars!"tokenizer_config.json", 17928),
   (chars!"turboquant_fold.json", 67779),
   (chars!"video_preprocessor_config.json", 385),
   (chars!"vocab.json", 6722759)]

/-- Each shard: file name, size, header length, header text. -/
def shards : List (List Char × Nat × Nat × List Char) :=
  [(chars!"model-00001-of-00006.safetensors", 2135170504, 16512, header0Chars),
   (chars!"model-00002-of-00006.safetensors", 2125783722, 69570, header1Chars),
   (chars!"model-00003-of-00006.safetensors", 2144032162, 49754, header2Chars),
   (chars!"model-00004-of-00006.safetensors", 2134686008, 49392, header3Chars),
   (chars!"model-00005-of-00006.safetensors", 2141037994, 49762, header4Chars),
   (chars!"model-00006-of-00006.safetensors", 1284217185, 21081, header5Chars)]

/-- The weight table of `model-00001-of-00006.safetensors` (`stHeader` of its header, `header_eq0`). -/
def table0 : Host.Mlx.Ffi.Header :=
  [(chars!"lm_head.biases", [248320, 80], 12),
   (chars!"lm_head.scales", [248320, 80], 12),
   (chars!"lm_head.weight", [248320, 640], 3),
   (chars!"model.language_model.embed_tokens.biases", [248320, 80], 12),
   (chars!"model.language_model.embed_tokens.scales", [248320, 80], 12),
   (chars!"model.language_model.embed_tokens.weight", [248320, 640], 3),
   (chars!"model.language_model.layers.0.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.0.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.0.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.0.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.0.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.0.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.0.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.0.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.0.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.0.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.0.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.0.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.0.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.0.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.0.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.0.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.1.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.1.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.1.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.1.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.1.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.1.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.1.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.1.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.1.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.2.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.2.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.2.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.2.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.2.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.2.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.2.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.2.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.2.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.2.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.2.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.2.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.2.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.2.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.2.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.2.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.3.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.3.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.3.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.3.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.3.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.3.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.3.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.3.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.3.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.3.self_attn.q_norm.weight", [256], 12),
   (chars!"mtp.fc.biases", [5120, 160], 12),
   (chars!"mtp.fc.scales", [5120, 160], 12),
   (chars!"mtp.fc.weight", [5120, 960], 3),
   (chars!"mtp.layers.0.input_layernorm.weight", [5120], 12),
   (chars!"mtp.layers.0.mlp.down_proj.biases", [5120, 272], 12),
   (chars!"mtp.layers.0.mlp.down_proj.scales", [5120, 272], 12),
   (chars!"mtp.layers.0.mlp.down_proj.weight", [5120, 1632], 3),
   (chars!"mtp.layers.0.mlp.gate_proj.biases", [17408, 80], 12),
   (chars!"mtp.layers.0.mlp.gate_proj.scales", [17408, 80], 12),
   (chars!"mtp.layers.0.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"mtp.layers.0.mlp.up_proj.biases", [17408, 80], 12),
   (chars!"mtp.layers.0.mlp.up_proj.scales", [17408, 80], 12),
   (chars!"mtp.layers.0.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"mtp.layers.0.post_attention_layernorm.weight", [5120], 12),
   (chars!"mtp.layers.0.self_attn.k_norm.weight", [256], 12),
   (chars!"mtp.layers.0.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"mtp.layers.0.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"mtp.layers.0.self_attn.k_proj.weight", [1024, 480], 3),
   (chars!"mtp.layers.0.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"mtp.layers.0.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"mtp.layers.0.self_attn.o_proj.weight", [5120, 576], 3),
   (chars!"mtp.layers.0.self_attn.q_norm.weight", [256], 12),
   (chars!"mtp.layers.0.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"mtp.layers.0.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"mtp.layers.0.self_attn.q_proj.weight", [12288, 480], 3),
   (chars!"mtp.layers.0.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"mtp.layers.0.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"mtp.layers.0.self_attn.v_proj.weight", [1024, 480], 3),
   (chars!"mtp.norm.weight", [5120], 12),
   (chars!"mtp.pre_fc_norm_embedding.weight", [5120], 12),
   (chars!"mtp.pre_fc_norm_hidden.weight", [5120], 12)]

/-- The weight table of `model-00002-of-00006.safetensors` (`stHeader` of its header, `header_eq1`). -/
def table1 : Host.Mlx.Ffi.Header :=
  [(chars!"model.language_model.layers.10.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.10.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.10.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.10.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.10.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.10.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.10.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.10.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.10.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.10.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.10.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.10.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.10.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.10.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.10.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.10.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.11.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.11.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.11.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.11.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.11.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.11.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.11.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.11.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.11.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.11.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.11.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.11.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.11.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.11.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.11.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.11.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.11.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.12.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.12.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.12.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.12.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.12.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.12.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.12.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.12.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.12.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.12.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.12.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.12.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.12.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.12.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.12.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.12.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.13.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.13.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.13.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.13.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.13.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.13.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.13.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.13.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.13.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.13.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.13.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.13.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.13.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.13.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.13.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.13.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.14.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.14.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.14.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.14.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.14.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.14.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.14.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.14.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.14.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.14.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.14.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.14.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.14.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.14.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.14.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.14.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.15.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.15.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.15.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.15.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.15.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.15.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.15.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.15.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.15.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.15.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.15.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.15.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.15.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.15.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.15.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.15.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.15.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.16.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.16.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.16.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.16.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.16.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.16.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.16.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.16.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.16.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.16.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.16.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.16.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.16.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.3.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.3.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.4.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.4.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.4.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.4.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.8.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.8.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.8.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.8.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.8.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.8.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.8.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.8.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.8.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.8.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.8.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.8.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.8.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.8.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.8.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.8.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.9.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.9.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.9.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.9.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.9.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.9.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.9.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.9.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.9.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.9.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.9.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.9.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.9.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.9.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.9.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.9.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.visual.blocks.0.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.0.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.0.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.0.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.0.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.0.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.0.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.0.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.0.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.0.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.0.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.0.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.1.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.1.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.1.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.1.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.1.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.1.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.1.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.1.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.1.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.1.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.1.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.1.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.10.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.10.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.10.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.10.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.10.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.10.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.10.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.10.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.10.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.10.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.10.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.10.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.11.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.11.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.11.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.11.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.11.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.11.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.11.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.11.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.11.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.11.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.11.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.11.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.12.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.12.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.12.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.12.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.12.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.12.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.12.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.12.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.12.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.12.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.12.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.12.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.13.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.13.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.13.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.13.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.13.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.13.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.13.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.13.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.13.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.13.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.13.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.13.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.14.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.14.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.14.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.14.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.14.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.14.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.14.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.14.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.14.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.14.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.14.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.14.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.15.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.15.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.15.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.15.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.15.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.15.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.15.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.15.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.15.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.15.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.15.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.15.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.16.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.16.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.16.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.16.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.16.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.16.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.16.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.16.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.16.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.16.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.16.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.16.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.17.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.17.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.17.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.17.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.17.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.17.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.17.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.17.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.17.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.17.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.17.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.17.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.18.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.18.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.18.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.18.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.18.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.18.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.18.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.18.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.18.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.18.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.18.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.18.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.19.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.19.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.19.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.19.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.19.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.19.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.19.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.19.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.19.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.19.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.19.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.19.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.2.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.2.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.2.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.2.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.2.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.2.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.2.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.2.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.2.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.2.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.2.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.2.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.20.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.20.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.20.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.20.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.20.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.20.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.20.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.20.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.20.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.20.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.20.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.20.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.21.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.21.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.21.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.21.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.21.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.21.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.21.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.21.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.21.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.21.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.21.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.21.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.22.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.22.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.22.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.22.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.22.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.22.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.22.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.22.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.22.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.22.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.22.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.22.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.23.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.23.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.23.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.23.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.23.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.23.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.23.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.23.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.23.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.23.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.23.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.23.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.24.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.24.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.24.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.24.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.24.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.24.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.24.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.24.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.24.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.24.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.24.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.24.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.25.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.25.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.25.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.25.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.25.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.25.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.25.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.25.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.25.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.25.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.25.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.25.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.26.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.26.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.26.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.26.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.26.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.26.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.26.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.26.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.26.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.26.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.26.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.26.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.3.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.3.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.3.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.3.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.3.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.3.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.3.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.3.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.3.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.3.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.3.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.3.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.4.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.4.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.4.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.4.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.4.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.4.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.4.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.4.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.4.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.4.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.4.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.4.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.5.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.5.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.5.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.5.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.5.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.5.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.5.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.5.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.5.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.5.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.5.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.5.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.6.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.6.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.6.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.6.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.6.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.6.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.6.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.6.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.6.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.6.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.6.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.6.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.7.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.7.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.7.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.7.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.7.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.7.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.7.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.7.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.7.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.7.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.7.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.7.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.8.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.8.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.8.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.8.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.8.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.8.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.8.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.8.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.8.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.8.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.8.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.8.norm2.weight", [1152], 12),
   (chars!"model.visual.blocks.9.attn.proj.bias", [1152], 12),
   (chars!"model.visual.blocks.9.attn.proj.weight", [1152, 1152], 12),
   (chars!"model.visual.blocks.9.attn.qkv.bias", [3456], 12),
   (chars!"model.visual.blocks.9.attn.qkv.weight", [3456, 1152], 12),
   (chars!"model.visual.blocks.9.mlp.linear_fc1.bias", [4304], 12),
   (chars!"model.visual.blocks.9.mlp.linear_fc1.weight", [4304, 1152], 12),
   (chars!"model.visual.blocks.9.mlp.linear_fc2.bias", [1152], 12),
   (chars!"model.visual.blocks.9.mlp.linear_fc2.weight", [1152, 4304], 12),
   (chars!"model.visual.blocks.9.norm1.bias", [1152], 12),
   (chars!"model.visual.blocks.9.norm1.weight", [1152], 12),
   (chars!"model.visual.blocks.9.norm2.bias", [1152], 12),
   (chars!"model.visual.blocks.9.norm2.weight", [1152], 12),
   (chars!"model.visual.merger.linear_fc1.bias", [4608], 12),
   (chars!"model.visual.merger.linear_fc1.weight", [4608, 4608], 12),
   (chars!"model.visual.merger.linear_fc2.bias", [5120], 12),
   (chars!"model.visual.merger.linear_fc2.weight", [5120, 4608], 12),
   (chars!"model.visual.merger.norm.bias", [1152], 12),
   (chars!"model.visual.merger.norm.weight", [1152], 12),
   (chars!"model.visual.patch_embed.proj.bias", [1152], 12),
   (chars!"model.visual.patch_embed.proj.weight", [1152, 3, 2, 16, 16], 12),
   (chars!"model.visual.pos_embed.weight", [2304, 1152], 12)]

/-- The weight table of `model-00003-of-00006.safetensors` (`stHeader` of its header, `header_eq2`). -/
def table2 : Host.Mlx.Ffi.Header :=
  [(chars!"model.language_model.layers.16.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.16.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.16.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.17.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.17.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.17.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.17.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.17.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.17.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.17.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.17.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.17.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.17.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.17.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.17.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.17.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.17.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.17.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.17.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.18.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.18.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.18.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.18.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.18.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.18.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.18.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.18.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.18.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.18.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.18.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.18.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.18.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.18.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.18.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.18.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.19.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.19.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.19.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.19.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.19.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.19.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.19.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.19.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.19.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.19.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.19.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.19.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.19.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.19.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.19.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.19.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.19.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.20.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.20.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.20.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.20.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.20.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.20.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.20.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.20.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.20.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.20.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.20.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.20.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.20.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.20.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.20.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.20.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.21.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.21.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.21.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.21.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.21.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.21.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.21.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.21.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.21.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.21.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.21.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.21.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.21.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.21.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.21.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.21.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.22.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.22.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.22.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.22.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.22.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.22.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.22.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.22.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.22.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.22.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.22.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.22.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.22.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.22.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.22.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.22.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.23.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.23.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.23.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.23.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.23.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.23.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.23.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.23.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.23.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.23.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.23.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.23.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.23.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.23.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.23.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.23.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.23.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.24.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.24.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.24.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.24.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.24.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.24.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.24.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.24.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.24.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.24.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.24.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.24.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.24.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.24.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.24.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.24.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.25.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.25.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.25.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.25.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.25.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.25.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.25.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.25.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.25.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.25.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.25.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.25.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.25.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.25.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.25.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.25.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.26.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.26.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.26.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.26.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.26.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.26.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.26.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.26.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.26.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.26.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.26.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.26.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.26.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.26.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.26.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.26.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.27.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.27.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.27.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.27.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.27.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.27.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.27.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.27.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.27.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.27.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.27.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.27.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.27.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.27.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.27.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.27.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.27.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.28.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.28.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.28.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.28.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.28.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.28.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.28.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.28.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.28.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.28.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.28.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.28.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.28.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.28.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.28.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.28.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.29.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.29.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.29.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.29.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.29.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.29.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.29.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.29.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.29.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.29.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.29.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.29.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.29.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.29.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.29.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.29.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.30.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.30.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.30.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.30.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.30.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.30.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.30.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.30.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.30.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.30.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.30.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.30.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.30.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.30.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.30.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.30.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.31.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.31.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.31.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.31.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.31.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.31.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.31.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.31.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.31.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.31.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.31.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.31.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.31.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.31.self_attn.q_norm.weight", [256], 12)]

/-- The weight table of `model-00004-of-00006.safetensors` (`stHeader` of its header, `header_eq3`). -/
def table3 : Host.Mlx.Ffi.Header :=
  [(chars!"model.language_model.layers.31.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.31.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.31.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.32.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.32.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.32.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.32.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.32.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.32.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.32.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.32.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.32.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.32.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.32.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.32.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.32.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.32.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.32.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.32.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.33.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.33.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.33.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.33.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.33.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.33.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.33.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.33.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.33.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.33.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.33.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.33.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.33.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.33.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.33.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.33.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.34.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.34.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.34.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.34.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.34.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.34.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.34.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.34.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.34.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.34.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.34.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.34.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.34.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.34.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.34.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.34.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.35.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.35.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.35.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.35.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.35.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.35.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.35.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.35.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.35.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.35.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.35.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.35.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.35.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.35.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.35.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.35.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.35.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.36.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.36.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.36.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.36.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.36.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.36.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.36.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.36.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.36.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.36.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.36.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.36.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.36.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.36.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.36.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.36.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.37.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.37.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.37.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.37.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.37.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.37.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.37.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.37.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.37.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.37.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.37.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.37.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.37.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.37.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.37.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.37.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.38.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.38.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.38.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.38.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.38.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.38.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.38.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.38.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.38.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.38.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.38.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.38.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.38.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.38.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.38.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.38.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.39.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.39.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.39.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.39.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.39.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.39.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.39.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.39.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.39.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.39.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.39.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.39.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.39.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.39.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.39.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.39.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.39.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.4.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.4.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.4.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.4.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.4.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.4.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.4.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.4.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.4.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.4.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.4.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.4.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.40.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.40.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.40.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.40.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.40.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.40.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.40.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.40.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.40.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.40.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.40.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.40.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.40.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.40.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.40.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.40.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.41.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.41.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.41.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.41.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.41.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.41.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.41.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.41.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.41.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.41.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.41.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.41.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.41.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.41.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.41.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.41.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.42.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.42.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.42.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.42.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.42.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.42.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.42.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.42.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.42.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.5.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.5.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.5.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.5.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.5.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.5.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.5.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.5.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.5.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.5.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.5.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.5.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.5.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.5.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.5.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.5.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.6.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.6.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.6.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.6.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.6.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.6.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.6.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.6.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.6.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.6.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.6.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.6.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.6.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.6.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.6.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.6.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.7.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.7.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.7.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.7.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.7.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.7.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.7.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.7.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.7.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.7.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.7.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.7.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.7.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.7.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.7.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.7.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.7.self_attn.v_proj.weight", [1024, 640], 3)]

/-- The weight table of `model-00005-of-00006.safetensors` (`stHeader` of its header, `header_eq4`). -/
def table4 : Host.Mlx.Ffi.Header :=
  [(chars!"model.language_model.layers.42.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.42.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.42.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.42.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.42.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.42.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.42.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.43.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.43.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.43.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.43.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.43.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.43.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.43.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.43.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.43.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.43.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.43.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.43.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.43.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.43.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.43.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.43.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.43.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.44.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.44.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.44.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.44.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.44.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.44.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.44.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.44.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.44.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.44.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.44.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.44.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.44.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.44.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.44.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.44.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.45.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.45.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.45.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.45.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.45.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.45.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.45.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.45.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.45.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.45.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.45.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.45.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.45.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.45.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.45.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.45.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.46.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.46.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.46.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.46.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.46.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.46.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.46.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.46.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.46.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.46.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.46.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.46.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.46.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.46.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.46.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.46.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.47.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.47.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.47.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.47.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.47.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.47.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.47.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.47.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.47.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.47.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.47.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.47.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.47.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.47.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.47.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.47.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.47.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.48.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.48.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.48.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.48.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.48.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.48.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.48.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.48.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.48.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.48.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.48.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.48.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.48.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.48.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.48.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.48.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.49.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.49.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.49.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.49.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.49.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.49.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.49.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.49.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.49.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.49.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.49.mlp.down_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.49.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.49.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.49.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.49.mlp.up_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.49.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.50.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.50.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.50.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.50.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.50.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.50.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.50.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.50.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.50.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.50.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.50.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.50.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.50.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.50.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.50.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.50.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.51.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.51.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.51.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.51.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.51.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.51.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.51.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.51.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.51.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.51.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.51.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.51.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.51.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.51.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.51.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.51.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.51.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.52.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.52.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.52.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.52.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.52.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.52.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.52.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.52.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.52.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.52.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.52.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.52.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.52.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.52.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.52.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.52.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.53.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.53.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.53.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.53.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_qkv.weight", [10240, 480], 3),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.53.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.53.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.53.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.53.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.53.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.53.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.53.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.53.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.53.mlp.gate_proj.weight", [17408, 320], 3),
   (chars!"model.language_model.layers.53.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.53.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.53.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.54.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.54.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.54.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.54.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.54.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.54.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.54.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.54.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.54.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.54.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.54.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.54.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.54.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.54.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.54.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.54.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.55.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.55.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.55.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.55.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.55.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.55.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.55.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.55.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.55.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.55.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.55.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.55.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.55.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.55.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.55.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.55.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.55.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.56.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.56.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.56.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.56.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.56.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.56.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.56.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.56.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.56.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.56.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.56.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.56.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.56.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.56.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.56.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.56.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.57.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.57.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.57.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.57.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.57.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.57.linear_attn.norm.weight", [128], 12)]

/-- The weight table of `model-00006-of-00006.safetensors` (`stHeader` of its header, `header_eq5`). -/
def table5 : Host.Mlx.Ffi.Header :=
  [(chars!"model.language_model.layers.57.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.57.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.57.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.57.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.57.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.57.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.57.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.57.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.57.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.57.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.58.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.58.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.58.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.58.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.58.linear_attn.in_proj_z.weight", [6144, 480], 3),
   (chars!"model.language_model.layers.58.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.58.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.58.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.58.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.58.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.58.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.58.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.58.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.58.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.58.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.58.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.59.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.59.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.59.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.59.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.59.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.59.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.59.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.59.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.59.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.59.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.59.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.59.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.59.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.59.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.59.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.59.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.59.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.60.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.60.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.60.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.60.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.60.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.60.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.60.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.60.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.60.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.60.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.60.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.60.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.60.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.60.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.60.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.60.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.61.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.61.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.61.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.61.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.61.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.61.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.61.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.61.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.61.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.61.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.61.mlp.down_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.61.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.61.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.61.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.61.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.61.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.62.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.62.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.62.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.62.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.62.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.62.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.62.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.62.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.62.linear_attn.out_proj.weight", [5120, 576], 3),
   (chars!"model.language_model.layers.62.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.62.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.62.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.62.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.62.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.62.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.62.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.63.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.63.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.63.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.63.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.63.mlp.gate_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.63.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.63.mlp.up_proj.weight", [17408, 640], 3),
   (chars!"model.language_model.layers.63.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.63.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.63.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.63.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.63.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.63.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.63.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.63.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.63.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.63.self_attn.v_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.norm.weight", [5120], 12)]

/-- The shards' weight tables, by file name. -/
def tables : List (List Char × Host.Mlx.Ffi.Header) :=
  [(chars!"model-00001-of-00006.safetensors", table0),
   (chars!"model-00002-of-00006.safetensors", table1),
   (chars!"model-00003-of-00006.safetensors", table2),
   (chars!"model-00004-of-00006.safetensors", table3),
   (chars!"model-00005-of-00006.safetensors", table4),
   (chars!"model-00006-of-00006.safetensors", table5)]

set_option maxRecDepth 1000000 in
kernel_rfl header_eq0 : stHeader header0Chars = some table0

set_option maxRecDepth 1000000 in
kernel_rfl header_eq1 : stHeader header1Chars = some table1

set_option maxRecDepth 1000000 in
kernel_rfl header_eq2 : stHeader header2Chars = some table2

set_option maxRecDepth 1000000 in
kernel_rfl header_eq3 : stHeader header3Chars = some table3

set_option maxRecDepth 1000000 in
kernel_rfl header_eq4 : stHeader header4Chars = some table4

set_option maxRecDepth 1000000 in
kernel_rfl header_eq5 : stHeader header5Chars = some table5

end Host.Load.Data
