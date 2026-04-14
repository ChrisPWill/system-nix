# TypeScript Patterns Reference

Quick-reference patterns for modern TypeScript.

## Branded Types (Nominal Typing)

Prevents logic errors by distinguishing between identical primitives (e.g., stopping you from accidentally passing a `ProductId` where a `UserId` is expected).

```typescript
export type Brand<K, T> = K & { __brand: T };

export type UserId = Brand<string, "UserId">;
export type Email = Brand<string, "Email">;

// Usage:
// const id = '123' as UserId;
```

## Example Class

Standard boilerplate for a modern TypeScript class using private fields and method chaining.

```typescript
export class DataContainer<T> {
  #data: T[] = [];
  #updatedAt: Date;

  constructor(initial?: T[]) {
    if (initial) this.#data = [...initial];
    this.#updatedAt = new Date();
  }

  get lastUpdated(): Date {
    return this.#updatedAt;
  }

  add(item: T): this {
    this.#data.push(item);
    this.#updatedAt = new Date();
    return this;
  }

  getAll(): readonly T[] {
    return Object.freeze([...this.#data]);
  }
}
```

## Result Pattern

A functional way to handle errors without `try/catch` blocks.

```typescript
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export const success = <T>(value: T): Result<T, never> => ({ ok: true, value });
export const failure = <E>(error: E): Result<never, E> => ({
  ok: false,
  error,
});

// Usage:
// const findUser = (id: string): Result<User, string> => {
//   return user ? success(user) : failure('User not found');
// };
```

## Memoization

A generic wrapper for caching function results based on arguments.

```typescript
export const memoize = <T extends (...args: any[]) => any>(fn: T): T => {
  const cache = new Map<string, ReturnType<T>>();
  return ((...args: Parameters<T>) => {
    const key = JSON.stringify(args);
    if (cache.has(key)) return cache.get(key);
    const result = fn(...args);
    cache.set(key, result);
    return result;
  }) as T;
};
```

## Async Utilities

Standard `sleep` helper and a simple promise timeout wrapper.

```typescript
export const sleep = (ms: number) =>
  new Promise((resolve) => setTimeout(resolve, ms));

export const withTimeout = <T>(promise: Promise<T>, ms: number): Promise<T> => {
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error("Timed out")), ms),
  );
  return Promise.race([promise, timeout]);
};
```

## Map/Set Helpers

A `getOrSet` pattern for working with nested collections in a Map.

```typescript
/**
 * Returns the value associated with the key, or sets it to the default if it doesn't exist.
 */
export const getOrSet = <K, V>(map: Map<K, V>, key: K, defaultValue: V): V => {
  if (!map.has(key)) map.set(key, defaultValue);
  return map.get(key)!;
};

// Usage:
// const groups = new Map<string, string[]>();
// getOrSet(groups, 'users', []).push('alice');
```
