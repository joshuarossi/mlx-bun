import type { CatalogError, CatalogFailureCode, ModelHostError, ResidencyFailure } from "@mlx-bun/app-core";

export class ModelHostFailure extends Error implements ModelHostError {
  constructor(readonly code: ResidencyFailure, message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = "ModelHostFailure";
  }
}

export class CatalogFailure extends Error implements CatalogError {
  constructor(readonly code: CatalogFailureCode, message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = "CatalogFailure";
  }
}
