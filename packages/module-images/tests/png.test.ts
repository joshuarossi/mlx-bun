// RGB bytes to PNG: a lossless round trip through the decoder, and the
// dimensions and byte count it refuses.
import { expect, test } from "bun:test";
import { decode } from "fast-png";
import { encodePng } from "../src/png";
import { pattern } from "./support";

test("encodes 8-bit RGB that decodes to the same pixels", () => {
  const pixels = pattern(5, 3, 200);
  const png = decode(encodePng({ width: 5, height: 3, pixels }));
  expect({ width: png.width, height: png.height, channels: png.channels, depth: png.depth }).toEqual({ width: 5, height: 3, channels: 3, depth: 8 });
  expect(png.data).toEqual(pixels);
});

test("refuses a byte count that is not width x height x 3, and non-positive dimensions", () => {
  expect(() => encodePng({ width: 2, height: 2, pixels: new Uint8Array(11) })).toThrow("expected 12 RGB bytes for 2x2, got 11");
  expect(() => encodePng({ width: 0, height: 2, pixels: new Uint8Array(0) })).toThrow("image dimensions must be positive integers, got 0x2");
});
