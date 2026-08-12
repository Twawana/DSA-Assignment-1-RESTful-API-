# DSA612S — Assignment 1, Question 1
## Distributed Library and Resource Management System


## 1. Folder structure

```
dsa612s-library-system/
├── service/             
│   ├── Ballerina.toml
│   ├── types.bal          
│   ├── datastore.bal       
│   └── service.bal         
├── client/                
│   ├── Ballerina.toml
│   ├── Config.toml        
│   ├── types.bal          
│   ├── client.bal         
│   └── main.bal             
└── docs/
    └── API.md              
```

## 2. Prerequisites

- Install the Ballerina Swan Lake distribution: https://ballerina.io/downloads/
- Check your version with `bal version`. If `Ballerina.toml` in `service/` or
  `client/` names a different `distribution` value and `bal build` complains,
  just update that line to match your installed version.

## 3. Running it

Open two terminals.

**Terminal 1 — start the service:**
```bash
cd service
bal run
```
It listens on `http://localhost:8080/api`.

**Terminal 2 — run the client:**
```bash
cd client
bal run
```
It talks to `http://localhost:8080/api` by default (see `client/Config.toml`).

Try option 1 (view all assets) and option 3 (add a new asset) — those two
flows are fully wired end-to-end already, so you can see the whole request
round-trip working before you build on top of it.

## 4. Task breakdown (maps to the mark scheme)

Suggested way to split this across a 4–8 person group. Each item below is a
`// TODO` in `service/service.bal` unless noted.

| Owner | Feature | Marks | Where |
|---|---|---|---|
| A | Finish asset CRUD: `PUT`/`DELETE /assets/[assetTag]` | 5 | `service.bal` |
| B | Institution/site filtering endpoints | 3 | `service.bal` |
| C | Overdue/maintenance check (compare `dueDate` to today via `ballerina/time`) | 5 | `service.bal` |
| D | Institution management: add/remove institutions | 5 | `service.bal` |
| E | Schedule management: add/remove schedules on an asset | 3 | `service.bal` |
| F | Components + work orders + tasks (add/remove/update) | — (part of CRUD + work orders) | `service.bal` |
| G | Error handling pass: make sure every endpoint returns sensible 400/404/409s | 2 | `service.bal` |
| H | Client: loaning/booking flow, overdue dashboard, schedule manager, campus filter view | 10 | `client/main.bal` + `client.bal` |

Whoever owns a service endpoint and whoever owns the matching client flow
should coordinate on the exact request/response shape — the `types.bal`
files in both projects currently match, keep them that way as you extend them.
