


       ┌───────┐
       │       │
       │ nginx │
       │       │
       └───┬───┘
           │
           │ Forward Basic Auth Header
           │
       ┌───▼───┐
       │ auth │
       │backend│
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

