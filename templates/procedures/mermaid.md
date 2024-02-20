# Procedure: {Nome da procedure}

## Diagramas

### Introdução

{Introdução sobre os diagramas}

### Diagrama 1 - {Nome do diagrama}

{Descrição breve do diagrama}

```mermaid
flowchart TD
    A[Square Rect] -- Link text --> B((Circle))
    A --> C(Round Rect)
    B --> D{Rhombus}
    C --> D

```

### Diagrama 2 - {Nome do diagrama}

{Descrição breve do diagrama}

```mermaid
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
```

### Diagrama 3 - {Nome do diagrama}

{Descrição breve do diagrama}

```mermaid
stateDiagram
    [*] --> NumLockOff
    NumLockOff --> NumLockOn : EvNumLockPressed
    NumLockOn --> NumLockOff : EvNumLockPressed
    NumLockOn --> [*]
```

### Diagrama 4 - {Nome do diagrama}

{Descrição breve do diagrama}

```mermaid
journey
    title My working day
    section Go to work
      Make tea: 5: Me
      Go upstairs: 3: Me
      Do work: 1: Me, Cat
    section Go home
      Go downstairs: 5: Me
      Sit down: 5: Me
```

{Outros diagramas que podem ajudar no entendimento da procedure}
