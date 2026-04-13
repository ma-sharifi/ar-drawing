# AR Drawing — MVP

An AR app that overlays dotted drawing templates on real-world surfaces so kids can trace and cut them out.

---

## Repository layout

```
ar-drawing/
├── ios/ARDrawing/          # SwiftUI + ARKit iOS app
│   ├── App/                # Entry point, root view
│   ├── Models/             # DrawingTemplate model
│   ├── Services/           # Remote + local template fetching
│   ├── Features/
│   │   ├── TemplateGallery/ # Template picker screen
│   │   └── ARView/          # AR overlay screen
│   └── Resources/          # Info.plist, asset catalog
│
└── backend/                # Spring Boot REST API
    └── src/main/java/com/ardrawing/
        ├── ArDrawingApplication.java
        ├── config/DataSeeder.java   # Demo seeds
        ├── controller/              # REST controllers
        ├── dto/                     # Response DTOs
        ├── model/                   # JPA entities
        ├── repository/              # Spring Data repos
        └── service/                 # Business logic
    └── src/main/resources/
        ├── application.properties
        └── static/templates/        # SVG + thumbnail files
```

---

## iOS — Getting Started

**Requirements:** Xcode 15+, iOS 16+, physical device with ARKit support.

1. Open `ios/ARDrawing/` in Xcode (create a new project and copy in the source files, or add an `.xcodeproj`).
2. Add the `NSCameraUsageDescription` key (already in `Info.plist`).
3. Add bundled SVG files to the asset catalog (or ship them from the backend at runtime).
4. Build & run on a real device — ARKit does not work in the Simulator.

**Key files:**

| File | Purpose |
|------|---------|
| `ARDrawingApp.swift` | App entry point |
| `TemplateGalleryView.swift` | Grid of available templates |
| `ARDrawingView.swift` | Camera + AR overlay screen |
| `ARCoordinator.swift` | `ARSCNViewDelegate` — detects planes, places SVG node |
| `TemplateService.swift` | Fetches templates (remote or local fallback) |

---

## Backend — Getting Started

**Requirements:** Java 21, Maven 3.9+.

```bash
cd backend
mvn spring-boot:run
```

The API is available at `http://localhost:8080`.

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/templates` | List all templates |
| GET | `/api/v1/templates?category=Animals` | Filter by category |
| GET | `/api/v1/templates/{id}` | Get one template |
| POST | `/api/v1/templates` | Add a template (metadata only) |

### Example response

```json
[
  {
    "id": "a1b2c3d4-...",
    "name": "Train",
    "category": "Vehicles",
    "svgURL": "/static/templates/train.svg",
    "thumbnailURL": "/static/templates/train.png"
  }
]
```

SVG files are served statically from `src/main/resources/static/templates/`.

---

## Architecture decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| DB (dev) | H2 in-memory | Zero setup for MVP |
| DB (prod) | PostgreSQL | Uncomment in `pom.xml` |
| iOS SVG rendering | UIImage from asset catalog | Avoids SVGKit dependency for MVP; swap when ready |
| AR surface detection | ARKit horizontal plane | Simplest starting point; extend to vertical later |
| API versioning | `/api/v1/` prefix | Easy to add v2 without breaking clients |

---

## Next steps

- [ ] iOS: Integrate SVGKit for live SVG → texture rendering
- [ ] iOS: Pinch-to-zoom / drag gesture for positioning
- [ ] iOS: Favourites persisted with SwiftData
- [ ] Backend: S3/GCS for SVG file storage
- [ ] Backend: PostgreSQL + Docker Compose setup
- [ ] Backend: SVG file upload endpoint (multipart)
- [ ] Android: Kotlin + ARCore equivalent
