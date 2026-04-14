import { add } from "./add";

describe("add", () => {
  it("should add two numbers correctly", () => {
    expect(add(1, 2)).toBe(3);
  });

  it("should handle negative numbers", () => {
    expect(add(-1, 5)).toBe(4);
  });
});
