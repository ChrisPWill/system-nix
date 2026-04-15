# Code Style Guidelines

## High level

- Follow language conventions
- Prefer implementing APIs that make use of information hiding - encapsulate information that is not needed internally.
- Prefer deep modules - modules that offer functionality by a simple interface. Hide complex internal logic.
- Consider whether the high level design should change as the implementation matures. Suggest such changes (but don't implement them unless approved)
- Prefer strong type safety, making use of features like branded types in languages like Typescript, but avoid excessively complex type gymnastics.

## Comments

- Prefer to explain "why" code is there rather than "what" the code is doing.
- Comments should capture design decisions and abstractions not already expressed in the code itself.
- Repeated comments that need detailed explanations can refer to a .md file in the same repository.
