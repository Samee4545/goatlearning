# API Updates — PDF Name Storage & Search

**Date:** 2026-03-31

## What Changed

| Area | Change |
|------|--------|
| `Chapter` model | Removed `coverImage`. Added `theoryFileName` |
| `Exercise` model | Added `problemFileName` and `solutionFileName` |
| Upload endpoints | Now return `filename` (original local name) alongside the URL |
| Chapter create/update | Now accept `theoryFileName`, `problemFileName`, `solutionFileName` |
| Chapter list | Supports `?search=` to filter by PDF filename |
| All fetch responses | `coverImage` removed, `theoryFileName` added everywhere |

---

## Base URL
```
http://localhost:3000/api/v1
```

---

## 1. POST /upload/single

**What changed:** Now returns `filename` (original device name) alongside the URL.

**Request:**
```
POST /api/v1/upload/single
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: Chapter_1_Theory.pdf
```

**Response:**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "url": "https://storage.googleapis.com/bucket/uploads/pdfs/1711234567-abc.pdf",
    "filename": "Chapter_1_Theory.pdf",
    "mimetype": "application/pdf",
    "size": 204800
  }
}
```

> Save both `url` and `filename` — you need them when creating a chapter.

**cURL:**
```bash
curl -X POST http://localhost:3000/api/v1/upload/single \
  -H "Authorization: Bearer <token>" \
  -F "file=@/path/to/Chapter_1_Theory.pdf"
```

---

## 2. POST /upload/multiple

**What changed:** Now returns `{ url, originalName }` per file instead of a plain URL array.

**Request:**
```
POST /api/v1/upload/multiple
Authorization: Bearer <token>
Content-Type: multipart/form-data

files: prob1.pdf, sol1.pdf
```

**Response:**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Files uploaded successfully",
  "data": {
    "files": [
      {
        "url": "https://storage.googleapis.com/bucket/uploads/pdfs/1711234567-p1.pdf",
        "originalName": "prob1.pdf"
      },
      {
        "url": "https://storage.googleapis.com/bucket/uploads/pdfs/1711234567-s1.pdf",
        "originalName": "sol1.pdf"
      }
    ],
    "count": 2
  }
}
```

**cURL:**
```bash
curl -X POST http://localhost:3000/api/v1/upload/multiple \
  -H "Authorization: Bearer <token>" \
  -F "files=@/path/to/prob1.pdf" \
  -F "files=@/path/to/sol1.pdf"
```

---

## 3. POST /chapter — Create Chapter

**What changed:** `coverImage` removed. `theoryFileName` added. Exercises now accept `problemFileName` and `solutionFileName`.

**Request Body:**
```json
{
  "chapterName": "Chapter 1: Introduction",
  "theory": "https://storage.googleapis.com/.../1711234567-abc.pdf",
  "theoryFileName": "Chapter_1_Theory.pdf",
  "isStandalone": true,
  "exercises": [
    {
      "problemUrl": "https://storage.googleapis.com/.../1711234567-p1.pdf",
      "problemFileName": "Exercise_1_Problem.pdf",
      "solutionUrl": "https://storage.googleapis.com/.../1711234567-s1.pdf",
      "solutionFileName": "Exercise_1_Solution.pdf"
    }
  ]
}
```

**Response:**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Chapter created successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Chapter 1: Introduction",
    "theory": "https://storage.googleapis.com/.../1711234567-abc.pdf",
    "theoryFileName": "Chapter_1_Theory.pdf",
    "createdAt": "2026-03-31T10:00:00.000Z",
    "exercises": [
      {
        "id": "exercise_id",
        "chapterId": "chapter_id",
        "problemUrl": "https://storage.googleapis.com/.../1711234567-p1.pdf",
        "problemFileName": "Exercise_1_Problem.pdf",
        "solutionUrl": "https://storage.googleapis.com/.../1711234567-s1.pdf",
        "solutionFileName": "Exercise_1_Solution.pdf"
      }
    ]
  }
}
```

**cURL:**
```bash
curl -X POST http://localhost:3000/api/v1/chapter \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "chapterName": "Chapter 1: Introduction",
    "theory": "https://storage.googleapis.com/.../theory.pdf",
    "theoryFileName": "Chapter_1_Theory.pdf",
    "isStandalone": true,
    "exercises": [
      {
        "problemUrl": "https://storage.googleapis.com/.../prob.pdf",
        "problemFileName": "Exercise_1_Problem.pdf",
        "solutionUrl": "https://storage.googleapis.com/.../sol.pdf",
        "solutionFileName": "Exercise_1_Solution.pdf"
      }
    ]
  }'
```

---

## 4. GET /chapter — Get Chapter List (+ Search)

**What changed:** `coverImage` removed from response. `theoryFileName` added. New `?search=` query param to filter by PDF filename.

**Query Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `search` | string | No | Filter by `theoryFileName` (case-insensitive, partial match) |

**Request (all):**
```
GET /api/v1/chapter
Authorization: Bearer <token>
```

**Request (search):**
```
GET /api/v1/chapter?search=Chapter_1
Authorization: Bearer <token>
```

**Response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter list retrieved successfully",
  "data": [
    {
      "id": "chapter_id",
      "chapterName": "Chapter 1: Introduction",
      "theory": "https://storage.googleapis.com/.../theory.pdf",
      "theoryFileName": "Chapter_1_Theory.pdf",
      "createdAt": "2026-03-31T10:00:00.000Z",
      "exerciseCount": 3,
      "isFavorite": false,
      "percent": 0
    }
  ]
}
```

**cURL (search):**
```bash
curl -X GET "http://localhost:3000/api/v1/chapter?search=Chapter_1" \
  -H "Authorization: Bearer <token>"
```

---

## 5. GET /chapter/:id — Get Chapter by ID

**What changed:** `coverImage` removed. `theoryFileName` added. Exercises now include `problemFileName` and `solutionFileName`.

**Response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter details retrieved successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Chapter 1: Introduction",
    "theory": "https://storage.googleapis.com/.../theory.pdf",
    "theoryFileName": "Chapter_1_Theory.pdf",
    "exercises": [
      {
        "id": "exercise_id",
        "chapterId": "chapter_id",
        "problemUrl": "https://storage.googleapis.com/.../prob.pdf",
        "problemFileName": "Exercise_1_Problem.pdf",
        "solutionUrl": "https://storage.googleapis.com/.../sol.pdf",
        "solutionFileName": "Exercise_1_Solution.pdf"
      }
    ]
  }
}
```

**cURL:**
```bash
curl -X GET http://localhost:3000/api/v1/chapter/<chapter_id> \
  -H "Authorization: Bearer <token>"
```

---

## 6. PUT /chapter/:id — Update Chapter

**What changed:** `coverImage` removed. `theoryFileName` accepted. Exercises accept `problemFileName` / `solutionFileName`.

**Request Body:**
```json
{
  "chapterName": "Chapter 1: Updated",
  "theory": "https://storage.googleapis.com/.../new_theory.pdf",
  "theoryFileName": "Chapter_1_Theory_v2.pdf",
  "exercises": [
    {
      "problemUrl": "https://storage.googleapis.com/.../new_prob.pdf",
      "problemFileName": "Exercise_1_Problem_v2.pdf",
      "solutionUrl": "https://storage.googleapis.com/.../new_sol.pdf",
      "solutionFileName": "Exercise_1_Solution_v2.pdf"
    }
  ]
}
```

**cURL:**
```bash
curl -X PUT http://localhost:3000/api/v1/chapter/<chapter_id> \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "chapterName": "Chapter 1: Updated",
    "theory": "https://storage.googleapis.com/.../new_theory.pdf",
    "theoryFileName": "Chapter_1_Theory_v2.pdf"
  }'
```

---

## 7. POST /chapter/:id — Add Exercises to Chapter

**What changed:** Accepts `problemFileName` and `solutionFileName` per exercise.

**Request Body:**
```json
{
  "exercises": [
    {
      "problemUrl": "https://storage.googleapis.com/.../prob2.pdf",
      "problemFileName": "Exercise_2_Problem.pdf",
      "solutionUrl": "https://storage.googleapis.com/.../sol2.pdf",
      "solutionFileName": "Exercise_2_Solution.pdf"
    }
  ]
}
```

**cURL:**
```bash
curl -X POST http://localhost:3000/api/v1/chapter/<chapter_id> \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "exercises": [
      {
        "problemUrl": "https://storage.googleapis.com/.../prob2.pdf",
        "problemFileName": "Exercise_2_Problem.pdf",
        "solutionUrl": "https://storage.googleapis.com/.../sol2.pdf",
        "solutionFileName": "Exercise_2_Solution.pdf"
      }
    ]
  }'
```

---

## 8. GET /chapter/exercise/:id — Get Exercises by Chapter

**What changed:** Now returns `problemFileName` and `solutionFileName`.

**Response:**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "get exercise successfully",
  "data": [
    {
      "id": "exercise_id",
      "chapterId": "chapter_id",
      "problemUrl": "https://storage.googleapis.com/.../prob.pdf",
      "problemFileName": "Exercise_1_Problem.pdf",
      "solutionUrl": "https://storage.googleapis.com/.../sol.pdf",
      "solutionFileName": "Exercise_1_Solution.pdf"
    }
  ]
}
```

**cURL:**
```bash
curl -X GET http://localhost:3000/api/v1/chapter/exercise/<chapter_id> \
  -H "Authorization: Bearer <token>"
```

---

## 9. Exercise Endpoints (GET /exercise, GET /exercise/all-solutions, GET /exercise/chapter/:id, GET /exercise/:id)

**What changed:** All exercise responses now include `problemFileName` and `solutionFileName`.

**Exercise object now looks like:**
```json
{
  "id": "exercise_id",
  "chapterId": "chapter_id",
  "chapterName": "Chapter 1",
  "problemUrl": "https://storage.googleapis.com/.../prob.pdf",
  "problemFileName": "Exercise_1_Problem.pdf",
  "solutionUrl": "https://storage.googleapis.com/.../sol.pdf",
  "solutionFileName": "Exercise_1_Solution.pdf"
}
```

---

## Other Affected Endpoints (response shape only)

These endpoints had no new params added — only their chapter response shape changed (`coverImage` removed, `theoryFileName` added):

| Endpoint | Method |
|----------|--------|
| `/content/my-content` | GET |
| `/content/folder/:folderId/chapters` | GET |
| `/chapter/folder/:id` | GET |
| `/favorites/my-favorites` | GET |
| `/complete` | GET |
| `/complete/admin` | GET |

**Chapter object in all above responses:**
```json
{
  "id": "chapter_id",
  "chapterName": "Chapter 1",
  "theory": "https://storage.googleapis.com/.../theory.pdf",
  "theoryFileName": "Chapter_1_Theory.pdf",
  "createdAt": "2026-03-31T10:00:00.000Z",
  "exerciseCount": 3,
  "isFavorite": false
}
```

---

## Recommended Flow (Upload → Create)

```
Step 1 — Upload theory PDF:
  POST /upload/single
  → get back { url, filename }

Step 2 — Upload each exercise PDF (problem + solution):
  POST /upload/single  (once per file)
  → get back { url, filename } for each

Step 3 — Create the chapter:
  POST /chapter
  → send theory, theoryFileName, and exercises with their urls + filenames
```
