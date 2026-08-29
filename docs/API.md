# API Reference

Base URL: `http://localhost:8080/api`

Legend: ✅ implemented as a worked example · 🔲 TODO stub, signature ready

| Method | Path | Status | Marks item |
|---|---|---|---|
| POST | `/assets` | ✅ | Create resource |
| GET | `/assets` | ✅ | View all assets (2 marks) |
| GET | `/assets/{assetTag}` | ✅ | Look up resource |
| PUT | `/assets/{assetTag}` | 🔲 | Update resource |
| DELETE | `/assets/{assetTag}` | 🔲 | Remove resource |
| GET | `/assets/institution/{institution}` | 🔲 | View by institution/site (3 marks) |
| GET | `/assets/institution/{institution}/site/{site}` | 🔲 | View by institution/site (3 marks) |
| GET | `/assets/overdue` | 🔲 | Status & booking schedule checks (5 marks) |
| GET | `/institutions` | ✅ | Manage institutions (5 marks) |
| POST | `/institutions` | 🔲 | Manage institutions (5 marks) |
| DELETE | `/institutions/{institutionId}` | 🔲 | Manage institutions (5 marks) |
| POST | `/assets/{assetTag}/components` | ✅ | Manage resources |
| DELETE | `/assets/{assetTag}/components/{compId}` | ✅ | Manage resources |
| POST | `/assets/{assetTag}/schedules` | 🔲 | Manage schedules (3 marks) |
| DELETE | `/assets/{assetTag}/schedules/{scheduleId}` | 🔲 | Manage schedules (3 marks) |
| POST | `/assets/{assetTag}/workorders` | ✅ | Work orders |
| PUT | `/assets/{assetTag}/workorders/{orderId}` | ✅ | Work orders |
| DELETE | `/assets/{assetTag}/workorders/{orderId}` | ✅ | Work orders |
| POST | `/assets/{assetTag}/workorders/{orderId}/tasks` | ✅ | Work order sub-tasks |

Not yet covered by any endpoint above: consistent 400 Bad Request handling
for malformed payloads (2 marks - "Error and Wrong API calls handling").
Add validation where it makes sense (e.g. reject an asset with a blank
`assetTag`) as you implement each TODO.

## Example requests

Create an asset:
```bash
curl -X POST http://localhost:8080/api/assets \
  -H "Content-Type: application/json" \
  -d '{
    "assetTag": "NUST-LIB-3DP-001",
    "name": "Pro-Series 3D Printer",
    "institution": "Namibia University of Science and Technology",
    "site": "Main Campus - Innovation Lab",
    "dateAcquired": "2024-03-10"
  }'
```

List all assets:
```bash
curl http://localhost:8080/api/assets
```

Add a component to an asset:
```bash
curl -X POST http://localhost:8080/api/assets/NUST-LIB-3DP-001/components \
  -H "Content-Type: application/json" \
  -d '{
    "compId": "",
    "name": "Print Head",
    "description": "Main extruder assembly"
  }'
```

Open a work order (status defaults to OPEN):
```bash
curl -X POST http://localhost:8080/api/assets/NUST-LIB-3DP-001/workorders \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "",
    "status": "",
    "description": "Print head clogged"
  }'
```
