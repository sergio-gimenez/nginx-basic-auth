# Basic Authentication Against RADIUS

```
       ┌───────┐
       │       │
       │ nginx │
       │       │
       └───┬───┘
           │
           │ Forward Basic Auth Header
           │
       ┌───▼───┐
       │ auth  │
       │backend│
       │       │
       └───┬───┘
           │
           │ PAP Auth
           │
       ┌───▼───┐
       │       │
       │radius │
       │       │
       └───────┘
```