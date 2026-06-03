# General Guidelines: A Philosophy of Software Design

## Strategic Programming

- **Prioritize Design:** Working code is not enough. The primary goal is a great design.
- **Investment Mindset:** Spend extra time now to save time in the future. Small investments in design add up to major improvements in velocity.

## Complexity is Incremental

- Complexity is caused by **dependencies** and **obscurity**.
- Aim for a system where a developer can work on any part without knowing much about the rest.

## Modular Design

- **Deep Modules:** Interfaces should be simple, while implementations provide significant functionality. Minimize the complexity that a user of a module must face.
- **Information Hiding:** Each module should encapsulate important design decisions that are not visible outside the module.
- **Information Leakage:** Avoid design decisions that affect multiple modules. If a change in one module requires a change in another, the design is leaking.

## Working with Complexity

- **Define Errors Out of Existence:** Design APIs so that errors are impossible or handled automatically, rather than throwing them to the caller.
- **Design it Twice:** Don't just implement the first idea. Consider at least two different approaches and compare them.

## Documentation

- **Explain the Why:** Comments should describe things that are not obvious from the code, such as the rationale behind a design choice or the high-level behavior of a complex algorithm.
