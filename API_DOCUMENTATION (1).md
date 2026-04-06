# Complete API Documentation

## Base URL
```
http://localhost:3000/api/v1
```

All endpoints require authentication unless otherwise specified.

---

## 💪 EXERCISE ENDPOINTS

**⚠️ IMPORTANT:** Exercises are linked to chapters via `chapterId`. When a chapter is deleted, ALL exercises with that `chapterId` MUST be automatically deleted (cascade delete). See Chapter DELETE endpoint for implementation details.

### 1. Get All Exercises
**Endpoint:** `GET /exercise`

**Authentication:** Not required (Public endpoint)

**Query Parameters:** None

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "All exercises fetched successfully",
  "data": [
    {
      "id": "exercise_id",
      "chapterId": "chapter_id",
      "chapterName": "Chapter 1: Introduction",
      "problemUrl": "https://example.com/problem1.pdf",
      "solutionUrl": "https://example.com/solution1.pdf"
    },
    {
      "id": "exercise_id2",
      "chapterId": "chapter_id2",
      "chapterName": "Chapter 2: Basics",
      "problemUrl": "https://example.com/problem2.pdf",
      "solutionUrl": "https://example.com/solution2.pdf"
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/exercise
```

---

### 2. Get Exercises by Chapter ID
**Endpoint:** `GET /exercise/chapter/:chapterId`

**Authentication:** Not required (Public endpoint)

**Path Parameters:**
- `chapterId` (string) - Chapter ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Exercises fetched successfully",
  "data": {
    "chapter": {
      "id": "chapter_id",
      "name": "Chapter 1: Introduction"
    },
    "exercises": [
      {
        "id": "exercise_id",
        "chapterId": "chapter_id",
        "chapterName": "Chapter 1: Introduction",
        "problemUrl": "https://example.com/problem1.pdf",
        "solutionUrl": "https://example.com/solution1.pdf"
      }
    ],
    "total": 1
  }
}
```

**Response (Error - 404):**
```json
{
  "statusCode": 404,
  "success": false,
  "message": "Chapter not found",
  "data": null
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/exercise/chapter/chapter_123
```

---

### 3. Get Single Exercise by ID
**Endpoint:** `GET /exercise/:exerciseId`

**Authentication:** Not required (Public endpoint)

**Path Parameters:**
- `exerciseId` (string) - Exercise ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Exercise fetched successfully",
  "data": {
    "id": "exercise_id",
    "chapterId": "chapter_id",
    "chapterName": "Chapter 1: Introduction",
    "problemUrl": "https://example.com/problem1.pdf",
    "solutionUrl": "https://example.com/solution1.pdf"
  }
}
```

**Response (Error - 404):**
```json
{
  "statusCode": 404,
  "success": false,
  "message": "Exercise not found",
  "data": null
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/exercise/exercise_123
```

---

## ❤️ FAVORITES ENDPOINTS

### 1. Toggle Favorite (Chapter Only)
**Endpoint:** `POST /favorites/toggle`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "chapterId": "chapter_id"
}
```

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Favorite added successfully.",
  "data": {
    "id": "favorite_id",
    "userId": "user_id",
    "chapterId": "chapter_id",
    "folderId": null
  }
}
```

---

### 2. Get My Favorites (Complete - Chapters + Folders)
**Endpoint:** `GET /favorites/my-favorites/all`

**Authentication:** Required (Bearer Token)

**Query Parameters:** None

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "User favorites fetched successfully with complete details",
  "data": [
    {
      "id": "chapter_id",
      "type": "chapter",
      "chapterName": "Chapter 1: Introduction",
      "coverImage": "https://example.com/image.jpg",
      "theory": "https://example.com/theory.pdf",
      "exerciseCount": 5,
      "isFavorite": true
    },
    {
      "id": "folder_id",
      "type": "folder",
      "name": "Mathematics",
      "chapterCount": 3,
      "isFavorite": true
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/favorites/my-favorites/all \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 3. Get All Favorites (Admin)
**Endpoint:** `GET /favorites`

**Authentication:** Not required

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "All favorites fetched successfully",
  "data": [
    {
      "id": "favorite_id",
      "userId": "user_id",
      "chapterId": "chapter_id",
      "folderId": null,
      "user": {
        "id": "user_id",
        "email": "user@example.com"
      },
      "chapter": {
        "id": "chapter_id",
        "chapterName": "Chapter 1",
        ...
      }
    }
  ]
}
```

---

### 4. Get Favorite by ID
**Endpoint:** `GET /favorites/:id`

**Authentication:** Not required

**Path Parameters:**
- `id` (string) - Favorite ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Favorite fetched successfully",
  "data": {
    "id": "favorite_id",
    "userId": "user_id",
    "chapterId": "chapter_id",
    "folderId": null,
    "user": {
      "id": "user_id",
      "name": "User Name",
      "username": "username",
      "email": "user@example.com"
    },
    "chapter": { ... }
  }
}
```

---

### 5. Delete Favorite
**Endpoint:** `DELETE /favorites/:id`

**Authentication:** Not required (but should require auth)

**Path Parameters:**
- `id` (string) - Favorite ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Favorite removed successfully",
  "data": { ... }
}
```

---

## 📤 UPLOAD ENDPOINTS

### 1. Upload Single File (Image or PDF)
**Endpoint:** `POST /upload/single`

**Authentication:** Required (Bearer Token)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request Body:**
- `file` (File) - Single image (JPEG, PNG, WEBP, GIF) or PDF file (Max: 50MB)

**Response (Success - 201):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "url": "https://storage.googleapis.com/...",
    "filename": "document.pdf",
    "mimetype": "application/pdf",
    "size": 2048576
  }
}
```

**Response (Error - 400):**
```json
{
  "statusCode": 400,
  "success": false,
  "message": "Only JPEG, PNG, WEBP, GIF images and PDF files are allowed",
  "data": null
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/upload/single \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/file.pdf"
```

---

### 2. Upload Multiple Files
**Endpoint:** `POST /upload/multiple`

**Authentication:** Required (Bearer Token)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request Body:**
- `files` (File[]) - Multiple files (Max: 10 files, 50MB each)

**Response (Success - 201):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Files uploaded successfully",
  "data": {
    "urls": [
      "https://storage.googleapis.com/...",
      "https://storage.googleapis.com/..."
    ],
    "count": 2
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/upload/multiple \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "files=@/path/to/file1.pdf" \
  -F "files=@/path/to/image.png"
```

---

## 📁 FOLDER ENDPOINTS

### 1. Create Folder (Auto-creates ContentOrder entry)
**Endpoint:** `POST /folder`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "name": "Advanced Mathematics",
  "userId": "user_id_string"
}
```

**Response (Success - 201):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Folder created successfully",
  "data": {
    "id": "folder_id",
    "name": "Advanced Mathematics",
    "userId": "user_id",
    "createdAt": "2025-11-17T10:30:00Z",
    "updatedAt": "2025-11-17T10:30:00Z"
  }
}
```

**Note:** When a folder is created, a `ContentOrder` entry is automatically created with the next available order number.

---

### 2. Get My Folders
**Endpoint:** `GET /folder/my`

**Authentication:** Required (Bearer Token)

**Query Parameters:** None

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folders fetched successfully",
  "data": [
    {
      "id": "folder_1",
      "name": "Mathematics",
      "createdAt": "2025-11-16T10:30:00Z",
      "updatedAt": "2025-11-16T10:30:00Z",
      "isSwapped": true
    },
    {
      "id": "folder_2",
      "name": "Physics",
      "createdAt": "2025-11-17T10:30:00Z",
      "updatedAt": "2025-11-17T10:30:00Z",
      "isSwapped": false
    }
  ]
}
```

---

### 3. Get All Folders
**Endpoint:** `GET /folder`

**Authentication:** Required (Bearer Token)

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folders fetched successfully",
  "data": [
    {
      "id": "folder_id",
      "name": "folder_name",
      "userId": "user_id",
      "createdAt": "2025-11-17T10:30:00Z",
      "updatedAt": "2025-11-17T10:30:00Z"
    }
  ]
}
```

---

### 4. Get Folder by ID
**Endpoint:** `GET /folder/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Folder ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folder fetched successfully",
  "data": {
    "id": "folder_id",
    "name": "Mathematics",
    "userId": "user_id",
    "createdAt": "2025-11-17T10:30:00Z",
    "updatedAt": "2025-11-17T10:30:00Z"
  }
}
```

---

### 5. Update Folder
**Endpoint:** `PUT /folder/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Folder ID

**Request Body:**
```json
{
  "name": "Updated Folder Name"
}
```

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folder updated successfully",
  "data": {
    "id": "folder_id",
    "name": "Updated Folder Name",
    "userId": "user_id",
    "createdAt": "2025-11-17T10:30:00Z",
    "updatedAt": "2025-11-17T10:31:00Z"
  }
}
```

---

### 6. Delete Folder (Cascades delete to ContentOrder, ChapterInFolder, SwapFolder)
**Endpoint:** `DELETE /folder/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Folder ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folder deleted successfully",
  "data": {
    "id": "folder_id",
    "name": "Mathematics",
    "userId": "user_id"
  }
}
```

---

### 7. Add Chapter to Folder
**Endpoint:** `POST /folder/add-chapter-folder`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "folderId": "folder_id",
  "chapterId": "chapter_id",
  "userId": "user_id"
}
```

**Response (Success - 201):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Chapter added to folder successfully",
  "data": {
    "id": "chapterInFolder_id",
    "folderId": "folder_id",
    "chapterId": "chapter_id",
    "userId": "user_id",
    "order": 1,
    "createdAt": "2025-11-17T10:30:00Z"
  }
}
```

**Note:** This creates a `ChapterInFolder` entry but does NOT create a `ContentOrder` entry. The chapter only appears within the folder, not in the main content list.

---

### 8. Reorder Folders (Bulk Reorder)
**Endpoint:** `POST /folder/swap`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "folderIds": ["folder_1", "folder_2", "folder_3"]
}
```

**Parameters:**
- `folderIds` (string[], required) - Array of folder IDs in desired order

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Folders reordered successfully",
  "data": null
}
```

**Example - Reorder 3 Folders:**
```bash
curl -X POST http://localhost:3000/api/v1/folder/swap \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "folderIds": ["folder_3", "folder_1", "folder_2"]
  }'
```

**How It Works:**
- Deletes all existing `swapFolder` records for the user
- Creates new records with indices as order values
- userId is extracted from JWT token automatically
- Useful for saving folder order after drag-drop operations
- Uses `swapFolder` table for custom ordering

**Example:**
```
BEFORE:
1. Mathematics (order: 1)
2. Physics     (order: 2)
3. Chemistry   (order: 3)

AFTER folderIds: ["Physics", "Chemistry", "Mathematics"]:
1. Physics     (order: 1)
2. Chemistry   (order: 2)
3. Mathematics (order: 3)
```

---

## 📚 CHAPTER ENDPOINTS

### 1. Create Chapter (Standalone or in Folder)
**Endpoint:** `POST /chapter`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "chapterName": "Chapter 1: Introduction",
  "coverImage": "https://example.com/image.jpg",
  "theory": "https://example.com/theory.pdf",
  "isStandalone": true,
  "userId": "user_id",
  "exercises": [
    {
      "problemUrl": "https://example.com/problem1.pdf",
      "solutionUrl": "https://example.com/solution1.pdf"
    }
  ]
}
```

**Fields:**
- `chapterName` (string, required) - Name of the chapter
- `coverImage` (string, required) - URL of cover image
- `theory` (string, required) - URL of theory document/PDF
- `isStandalone` (boolean, optional) - If true and userId provided, creates ContentOrder entry
- `userId` (string, optional) - Required if isStandalone is true
- `exercises` (array, optional) - Array of exercises with problemUrl and solutionUrl

**Response (Success - 201):**
```json
{
  "statusCode": 201,
  "success": true,
  "message": "Chapter created successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Chapter 1: Introduction",
    "coverImage": "https://example.com/image.jpg",
    "theory": "https://example.com/theory.pdf",
    "createdAt": "2025-11-17T10:30:00Z",
    "exercises": [
      {
        "id": "exercise_id",
        "chapterId": "chapter_id",
        "problemUrl": "https://example.com/problem1.pdf",
        "solutionUrl": "https://example.com/solution1.pdf"
      }
    ]
  }
}
```

**Note:** When `isStandalone: true` and `userId` is provided, a `ContentOrder` entry is automatically created.

---

### 2. Get All Chapters for User
**Endpoint:** `GET /chapter`

**Authentication:** Required (Bearer Token)

**Query Parameters:** None

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapters fetched successfully",
  "data": [
    {
      "id": "chapter_id",
      "chapterName": "Chapter 1",
      "coverImage": "https://example.com/image.jpg",
      "theory": "https://example.com/theory.pdf",
      "createdAt": "2025-11-17T10:30:00Z",
      "exerciseCount": 5,
      "isFavorite": true,
      "percent": 50
    }
  ]
}
```

---

### 3. Get Chapter by ID
**Endpoint:** `GET /chapter/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Chapter ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter fetched successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Chapter 1",
    "coverImage": "https://example.com/image.jpg",
    "theory": "https://example.com/theory.pdf",
    "exercises": [
      {
        "id": "exercise_id",
        "problemUrl": "https://example.com/problem.pdf",
        "solutionUrl": "https://example.com/solution.pdf"
      }
    ]
  }
}
```

---

### 4. Update Chapter
**Endpoint:** `PUT /chapter/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Chapter ID

**Request Body:**
```json
{
  "chapterName": "Updated Chapter Name",
  "coverImage": "https://example.com/new-image.jpg",
  "theory": "https://example.com/new-theory.pdf"
}
```

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter updated successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Updated Chapter Name",
    "coverImage": "https://example.com/new-image.jpg",
    "theory": "https://example.com/new-theory.pdf",
    "createdAt": "2025-11-17T10:30:00Z",
    "updatedAt": "2025-11-17T10:35:00Z"
  }
}
```

---

### 5. Delete Chapter (Cascades delete to all related records including ContentOrder and Exercises)
**Endpoint:** `DELETE /chapter/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Chapter ID

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter deleted successfully",
  "data": {
    "id": "chapter_id",
    "chapterName": "Chapter 1"
  }
}
```

**⚠️ CRITICAL - CASCADE DELETE REQUIREMENT:**
When a chapter is deleted, the backend MUST automatically delete ALL related records in this order:

1. **Delete all Exercises** where `chapterId` matches (REQUIRED - Currently broken if not implemented)
2. **Delete all Favorites** where `chapterId` matches
3. **Delete all ChapterInFolder** entries where `chapterId` matches
4. **Delete all ContentOrder** entries where `chapterId` matches
5. **Delete all UserChapter** entries where `chapterId` matches
6. **Finally, delete the Chapter** itself

**Backend Implementation Required:**
```javascript
// In your chapter controller, the delete function should:
await prisma.$transaction(async (tx) => {
  // Step 1: Delete all exercises for this chapter (CRITICAL)
  await tx.exercise.deleteMany({ where: { chapterId: id } });
  
  // Step 2-5: Delete other related records
  await tx.favorite.deleteMany({ where: { chapterId: id } });
  await tx.chapterInFolder.deleteMany({ where: { chapterId: id } });
  await tx.contentOrder.deleteMany({ where: { chapterId: id } });
  await tx.userChapter.deleteMany({ where: { chapterId: id } });
  
  // Step 6: Delete the chapter
  const deleted = await tx.chapter.delete({ where: { id } });
  return deleted;
});
```

**Or use Prisma Schema cascade:**
```prisma
model Exercise {
  id        String  @id @default(auto()) @map("_id") @db.ObjectId
  chapterId String  @db.ObjectId
  chapter   Chapter @relation(fields: [chapterId], references: [id], onDelete: Cascade)
  // ... other fields
}
```

---

### 6. Reorder Chapters (Bulk Reorder - Root Level)
**Endpoint:** `POST /chapter/swipe`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "chapterIds": ["chapter_1", "chapter_3", "chapter_2"]
}
```

**Parameters:**
- `chapterIds` (string[], required) - Array of chapter IDs in desired order

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapters reordered successfully",
  "data": null
}
```

**Example - Reorder User's Root-Level Chapters:**
```bash
curl -X POST http://localhost:3000/api/v1/chapter/swipe \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "chapterIds": ["chapter_2", "chapter_1", "chapter_3"]
  }'
```

**How It Works:**
- Reorders all chapters in user's custom chapter list (root-level, not in folders)
- Deletes all existing `userChapter` records for the user
- Creates new records with indices as order values
- userId is extracted from JWT token automatically
- Uses `userChapter` table for custom ordering
- Useful for bulk reordering after drag-drop operations

**Note:** This only applies to root-level chapters, not chapters within folders. Use `/content/reorder-chapters-in-folder` for chapters inside folders.

---

### 7. Remove Chapter from Folder
**Endpoint:** `DELETE /chapter/out/:id`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `id` (string) - Chapter ID to remove from folder

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapter removed from folder successfully",
  "data": null
}
```

**Example - Remove Chapter from Folder and Make it Standalone:**
```bash
curl -X DELETE http://localhost:3000/api/v1/chapter/out/chapter_1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**How It Works:**
- Removes chapter from `chapterInFolder` table
- Automatically adds it to `contentOrder` as a standalone chapter
- Finds the max order in `contentOrder` and assigns next order
- userId is extracted from JWT token automatically
- Chapter appears in main content list after removal
- Useful for moving chapters out of folders

**Example Scenario:**
```
BEFORE:
Main Content:
1. Chapter A
2. Folder X
   └─ Chapter B  ← Removing this
   └─ Chapter C
3. Chapter D

AFTER removing Chapter B:
Main Content:
1. Chapter A
2. Folder X
   └─ Chapter C
3. Chapter D
4. Chapter B  ← Now standalone
```

---

## 📦 CONTENT ORDERING ENDPOINTS

### 1. Get Mixed Content (Folders + Standalone Chapters)
**Endpoint:** `GET /content/my-content`

**Authentication:** Required (Bearer Token)

**Query Parameters:**
- `sort` (string, optional) - 'asc' or 'desc' for ordering (default: 'asc')

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Mixed content fetched successfully",
  "data": [
    {
      "id": "chapter_1",
      "type": "chapter",
      "chapterName": "Chapter A",
      "coverImage": "https://example.com/image.jpg",
      "theory": "https://example.com/theory.pdf",
      "createdAt": "2025-11-15T10:30:00Z",
      "order": 1,
      "chapterId": "chapter_1",
      "exerciseCount": 5,
      "isFavorite": true
    },
    {
      "id": "folder_1",
      "type": "folder",
      "name": "Mathematics",
      "createdAt": "2025-11-16T10:30:00Z",
      "order": 2,
      "folderId": "folder_1",
      "chapterCount": 3,
      "isFavorite": false
    },
    {
      "id": "chapter_2",
      "type": "chapter",
      "chapterName": "Chapter B",
      "coverImage": "https://example.com/image2.jpg",
      "theory": "https://example.com/theory2.pdf",
      "createdAt": "2025-11-17T10:30:00Z",
      "order": 3,
      "chapterId": "chapter_2",
      "exerciseCount": 8,
      "isFavorite": true
    }
  ]
}
```

**Notes:**
- `isFavorite` field indicates if the item (chapter or folder) is marked as favorite by the authenticated user
- When user is not authenticated (no userId), all items will have `isFavorite: false`
- For **chapters**: isFavorite is checked against `Favorite.chapterId`
- For **folders**: isFavorite is checked against `Favorite.folderId`

**Example Requests:**
```bash
# Ascending order (default) - with authentication
curl -X GET "http://localhost:3000/api/v1/content/my-content" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Descending order - with authentication
curl -X GET "http://localhost:3000/api/v1/content/my-content?sort=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Without authentication - all items will have isFavorite: false
curl -X GET "http://localhost:3000/api/v1/content/my-content"
```

---

### 2. Reorder Items in Main Content List (Drag & Drop)
**Endpoint:** `POST /content/reorder-content`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "itemId": "chapter_id_or_folder_id",
  "newPosition": 2
}
```

**Parameters:**
- `itemId` (string, required) - ID of the chapter or folder to move
- `newPosition` (number, required) - New position (1-based index, e.g., 1 = first position)

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Content reordered successfully",
  "data": null
}
```

**Example - Move Chapter from Position 1 to Position 3:**
```bash
curl -X POST http://localhost:3000/api/v1/content/reorder-content \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "itemId": "chapter_1",
    "newPosition": 3
  }'
```

**How It Works - Reordering Algorithm:**

The reordering function efficiently moves items with minimal database updates:

**Scenario 1: Moving Down (Current Position 1 → New Position 3)**
```
BEFORE:
1. Chapter A (order: 1)
2. Chapter B (order: 2)
3. Folder X  (order: 3)
4. Chapter C (order: 4)
5. Chapter D (order: 5)

PROCESS:
- Items between old and new position shift UP by 1
- Chapter B: order 2 → 1
- Folder X: order 3 → 2
- Chapter A moves to new position: order 1 → 3

AFTER:
1. Chapter B (order: 1)
2. Folder X  (order: 2)
3. Chapter A (order: 3)  ← New position
4. Chapter C (order: 4)
5. Chapter D (order: 5)
```

**Scenario 2: Moving Up (Current Position 5 → New Position 2)**
```
BEFORE:
1. Chapter A (order: 1)
2. Chapter B (order: 2)
3. Folder X  (order: 3)
4. Chapter C (order: 4)
5. Chapter D (order: 5)

PROCESS:
- Items between new and old position shift DOWN by 1
- Chapter B: order 2 → 3
- Folder X: order 3 → 4
- Chapter D moves to new position: order 5 → 2

AFTER:
1. Chapter A (order: 1)
2. Chapter D (order: 2)  ← New position
3. Chapter B (order: 3)
4. Folder X  (order: 4)
5. Chapter C (order: 5)
```

**Key Points:**
- Uses 1-based indexing (position 1 is first)
- Only shifts items between current and new position (efficient)
- Executes in atomic database transaction (all succeed or all fail)
- No gaps in order numbers
- userId is extracted from JWT token automatically

---

### 3. Swap Two Items in Main Content List (Deprecated)
**Endpoint:** `POST /content/swap-content`

**Status:** ⚠️ DEPRECATED - Use `/reorder-content` instead

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "item1Id": "chapter_id_or_folder_id",
  "item2Id": "chapter_id_or_folder_id"
}
```

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Content swapped successfully",
  "data": null
}
```

**Example - Swap Chapter A and Folder B:**
```bash
curl -X POST http://localhost:3000/api/v1/content/swap-content \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item1Id": "chapter_1",
    "item2Id": "folder_1"
  }'
```

**How It Works:**
- Directly swaps order values between two items
- Both items must belong to the user
- Limited to simple 2-item swaps only

---

### 4. Get Chapters in Folder (with proper ordering)
**Endpoint:** `GET /content/folder/:folderId/chapters`

**Authentication:** Required (Bearer Token)

**Path Parameters:**
- `folderId` (string) - Folder ID

**Query Parameters:**
- `sort` (string, optional) - 'asc' or 'desc' for ordering (default: 'asc')

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapters in folder fetched successfully",
  "data": [
    {
      "id": "chapter_1",
      "chapterName": "Chapter 1",
      "coverImage": "https://example.com/image.jpg",
      "theory": "https://example.com/theory.pdf",
      "createdAt": "2025-11-17T10:30:00Z",
      "exerciseCount": 5,
      "isFavorite": true,
      "isComplete": false,
      "order": 1
    },
    {
      "id": "chapter_2",
      "chapterName": "Chapter 2",
      "coverImage": "https://example.com/image2.jpg",
      "theory": "https://example.com/theory2.pdf",
      "createdAt": "2025-11-17T10:35:00Z",
      "exerciseCount": 8,
      "isFavorite": false,
      "isComplete": true,
      "order": 2
    }
  ]
}
```

**Example:**
```bash
# Ascending order (default)
curl -X GET "http://localhost:3000/api/v1/content/folder/folder_1/chapters" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Descending order
curl -X GET "http://localhost:3000/api/v1/content/folder/folder_1/chapters?sort=desc" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 5. Reorder Chapters Within a Folder (Drag & Drop)
**Endpoint:** `POST /content/reorder-chapters-in-folder`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "folderId": "folder_id",
  "chapterId": "chapter_id",
  "newPosition": 2
}
```

**Parameters:**
- `folderId` (string, required) - ID of the folder
- `chapterId` (string, required) - ID of the chapter to move
- `newPosition` (number, required) - New position within folder (1-based index)

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapters reordered successfully",
  "data": null
}
```

**Example - Move Chapter from Position 2 to Position 4 in a Folder:**
```bash
curl -X POST http://localhost:3000/api/v1/content/reorder-chapters-in-folder \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "folderId": "folder_1",
    "chapterId": "chapter_2",
    "newPosition": 4
  }'
```

**How It Works:**
- Same efficient reordering algorithm as main content reordering
- Works within a specific folder only
- Only affects chapters in that folder
- userId is extracted from JWT token automatically
- Chapters are reordered in `chapterInFolder` table

**Example Scenario:**
```
BEFORE:
Folder: "Mathematics"
1. Chapter 1: Algebra      (order: 1)
2. Chapter 2: Geometry     (order: 2)  ← Moving from here
3. Chapter 3: Calculus     (order: 3)
4. Chapter 4: Trigonometry (order: 4)

AFTER (newPosition: 4):
Folder: "Mathematics"
1. Chapter 1: Algebra      (order: 1)
2. Chapter 3: Calculus     (order: 2)  ← Shifted up
3. Chapter 4: Trigonometry (order: 3)  ← Shifted up
4. Chapter 2: Geometry     (order: 4)  ← New position
```

---

### 6. Swap Chapters Within a Folder (Deprecated)
**Endpoint:** `POST /content/swap-chapters-in-folder`

**Status:** ⚠️ DEPRECATED - Use `/reorder-chapters-in-folder` instead

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "folderId": "folder_id",
  "chapter1Id": "chapter_id_1",
  "chapter2Id": "chapter_id_2"
}
```

**Response (Success - 200):**
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Chapters swapped successfully",
  "data": null
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/v1/content/swap-chapters-in-folder \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "folderId": "folder_1",
    "chapter1Id": "chapter_1",
    "chapter2Id": "chapter_2"
  }'
```

**How It Works:**
- Directly swaps order values between two chapters
- Both chapters must be in the specified folder
- Limited to simple 2-item swaps only

---

## 🗄️ DATABASE SCHEMA

### ContentOrder Table
```
{
  id: String (ObjectId)
  userId: String (ObjectId) - Reference to User
  folderId: String? (ObjectId) - null if standalone chapter
  chapterId: String? (ObjectId) - null if folder
  order: Int - Position in sequence (1, 2, 3...)
  createdAt: DateTime
  updatedAt: DateTime
}

Unique Constraint: [userId, folderId, chapterId]

Used by:
- GET /content/my-content - Retrieves folders and standalone chapters in order
- POST /content/reorder-content - Reorders items in main list
- POST /content/swap-content - Swaps two items (deprecated)
```

### ChapterInFolder Table
```
{
  id: String (ObjectId)
  folderId: String (ObjectId)
  chapterId: String (ObjectId)
  userId: String (ObjectId)
  order: Int - Position within folder
  createdAt: DateTime
  updatedAt: DateTime
}

Used by:
- GET /content/folder/:folderId/chapters - Retrieves chapters in folder in order
- POST /content/reorder-chapters-in-folder - Reorders chapters within folder
- POST /content/swap-chapters-in-folder - Swaps two chapters in folder (deprecated)
```

### SwapFolder Table
```
{
  id: String (ObjectId)
  userId: String (ObjectId) - Reference to User
  folderId: String (ObjectId)
  order: Int - Position in folder list
  createdAt: DateTime
  updatedAt: DateTime
}

Used by:
- GET /folder/my - Retrieves user's folders in custom order
- POST /folder/swap - Bulk reorders all folders for user
```

### UserChapter Table
```
{
  id: String (ObjectId)
  userId: String (ObjectId) - Reference to User
  chapterId: String (ObjectId)
  order: Int - Position in chapter list
  createdAt: DateTime
  updatedAt: DateTime
}

Used by:
- POST /chapter/swipe - Bulk reorders all root-level chapters for user
```

---

## ⚙️ FIREBASE SETUP INSTRUCTIONS

### 1. Create Firebase Configuration File
Create `serviceAccountKey.json` in project root:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-key-id",
  "private_key": "your-private-key",
  "client_email": "your-service-account@project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "...",
  "client_x509_cert_url": "..."
}
```

### 2. Update .env File
```
FIREBASE_STORAGE_BUCKET=your-bucket-name.appspot.com
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}  # Or path to serviceAccountKey.json
```

### 3. Install Firebase Admin SDK
```bash
npm install firebase-admin
```

---

## 🔄 WORKFLOW EXAMPLES

### Example 1: Create Folder with Chapters
```bash
# 1. Create Folder
curl -X POST http://localhost:3000/api/v1/folder \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name":"Math","userId":"user123"}'
# Returns: folder_id = "f123"

# 2. Create Chapter 1
curl -X POST http://localhost:3000/api/v1/chapter \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "chapterName":"Ch1",
    "coverImage":"url1",
    "theory":"url2",
    "exercises":[{"problemUrl":"url","solutionUrl":"url"}]
  }'
# Returns: chapter_id = "c123"

# 3. Add Chapter to Folder
curl -X POST http://localhost:3000/api/v1/folder/add-chapter-folder \
  -H "Authorization: Bearer TOKEN" \
  -d '{"folderId":"f123","chapterId":"c123","userId":"user123"}'

# 4. Get Chapters in Folder
curl -X GET http://localhost:3000/api/v1/content/folder/f123/chapters \
  -H "Authorization: Bearer TOKEN"
```

### Example 2: Create Standalone Chapters and View in Order
```bash
# 1. Create Standalone Chapter 1
curl -X POST http://localhost:3000/api/v1/chapter \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "chapterName":"Physics 101",
    "coverImage":"url1",
    "theory":"url2",
    "isStandalone":true,
    "userId":"user123"
  }'
# Returns: chapter_id = "ch1"

# 2. Create Folder
curl -X POST http://localhost:3000/api/v1/folder \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name":"Advanced","userId":"user123"}'
# Returns: folder_id = "f1"

# 3. Create Standalone Chapter 2
curl -X POST http://localhost:3000/api/v1/chapter \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "chapterName":"Chemistry 101",
    "coverImage":"url3",
    "theory":"url4",
    "isStandalone":true,
    "userId":"user123"
  }'
# Returns: chapter_id = "ch2"

# 4. Get Mixed Content (will show in order: Ch1, Folder, Ch2)
curl -X GET http://localhost:3000/api/v1/content/my-content \
  -H "Authorization: Bearer TOKEN"

# 5. Swap Chapter 1 and Folder
curl -X POST http://localhost:3000/api/v1/content/swap-content \
  -H "Authorization: Bearer TOKEN" \
  -d '{"item1Id":"ch1","item2Id":"f1"}'

# 6. Get Mixed Content again (will show in order: Folder, Ch1, Ch2)
curl -X GET http://localhost:3000/api/v1/content/my-content \
  -H "Authorization: Bearer TOKEN"
```

---

## 🔐 Authentication

All endpoints (except Auth endpoints) require a Bearer token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

The token should be obtained from the Authentication endpoints:
- `POST /auth/login` - Login and get token
- `POST /auth/register` - Register and get token
- `POST /auth/refresh` - Refresh token

---

## ✅ SUMMARY TABLE

| Endpoint | Method | Type | Purpose | Auth | Status |
|----------|--------|------|---------|------|--------|
| `/exercise` | GET | Exercise | Get all exercises | ❌ No | ✅ Current |
| `/exercise/chapter/:chapterId` | GET | Exercise | Get exercises by chapter ID | ❌ No | ✅ Current |
| `/exercise/:exerciseId` | GET | Exercise | Get single exercise by ID | ❌ No | ✅ Current |
| `/favorites/toggle` | POST | Favorite | Toggle chapter favorite | ✅ Yes | ✅ Current |
| `/favorites/my-favorites/all` | GET | Favorite | Get all user favorites (chapters + folders) | ✅ Yes | ✅ Current |
| `/favorites` | GET | Favorite | Get all favorites (admin) | ❌ No | ✅ Current |
| `/favorites/:id` | GET | Favorite | Get favorite by ID | ❌ No | ✅ Current |
| `/favorites/:id` | DELETE | Favorite | Delete favorite | ❌ No | ✅ Current |
| `/favorites/user/all` | GET | Favorite | Get user favorites (chapters only) | ✅ Yes | ✅ Current |
| `/upload/single` | POST | Upload | Upload single file | ✅ Yes | ✅ Current |
| `/upload/multiple` | POST | Upload | Upload multiple files | ✅ Yes | ✅ Current |
| `/folder` | POST | Folder | Create folder (auto ContentOrder) | ✅ Yes | ✅ Current |
| `/folder` | GET | Folder | Get all folders | ✅ Yes | ✅ Current |
| `/folder/my` | GET | Folder | Get user's folders with custom order | ✅ Yes | ✅ Current |
| `/folder/:id` | GET | Folder | Get folder by ID | ✅ Yes | ✅ Current |
| `/folder/:id` | PUT | Folder | Update folder | ✅ Yes | ✅ Current |
| `/folder/:id` | DELETE | Folder | Delete folder (cascades) | ✅ Yes | ✅ Current |
| `/folder/add-chapter-folder` | POST | Folder | Add chapter to folder | ✅ Yes | ✅ Current |
| `/folder/swap` | POST | Folder | Bulk reorder folders | ✅ Yes | ✅ Current |
| `/chapter` | POST | Chapter | Create chapter (auto ContentOrder if standalone) | ✅ Yes | ✅ Current |
| `/chapter` | GET | Chapter | Get user's chapters | ✅ Yes | ✅ Current |
| `/chapter/:id` | GET | Chapter | Get chapter by ID | ✅ Yes | ✅ Current |
| `/chapter/:id` | PUT | Chapter | Update chapter | ✅ Yes | ✅ Current |
| `/chapter/:id` | DELETE | Chapter | Delete chapter (cascades) | ✅ Yes | ✅ Current |
| `/chapter/swipe` | POST | Chapter | Bulk reorder root-level chapters | ✅ Yes | ✅ Current |
| `/chapter/out/:id` | DELETE | Chapter | Remove chapter from folder (make standalone) | ✅ Yes | ✅ Current |
| `/content/my-content` | GET | Content | Get mixed content (folders + chapters) with isFavorite | ✅ Optional | ✅ Current |
| `/content/reorder-content` | POST | Content | Reorder items in main list (drag-drop) | ✅ Yes | ✅ Current |
| `/content/swap-content` | POST | Content | Swap items in main list | ✅ Yes | ⚠️ Deprecated |
| `/content/folder/:id/chapters` | GET | Content | Get chapters in folder with order | ✅ Optional | ✅ Current |
| `/content/reorder-chapters-in-folder` | POST | Content | Reorder chapters in folder (drag-drop) | ✅ Yes | ✅ Current |
| `/content/swap-chapters-in-folder` | POST | Content | Swap chapters in folder | ✅ Yes | ⚠️ Deprecated |

---

## 📋 NOTES

### Content & Ordering

1. **Auto ContentOrder Creation:**
   - When a folder is created, a ContentOrder entry is automatically created
   - When a standalone chapter is created (with isStandalone: true), a ContentOrder entry is automatically created

2. **Adding Chapters to Folders:**
   - Creating a ChapterInFolder entry does NOT create a ContentOrder entry
   - The chapter only appears within the folder, not in the main content list
   - Standalone chapters can be added to folders via `/folder/add-chapter-folder`

3. **Removing Chapters from Folders:**
   - Use `DELETE /chapter/out/:id` to remove a chapter from a folder
   - Automatically becomes a standalone chapter in the main content list
   - Gets the next available order in ContentOrder table

4. **Ordering System - Multi-Level:**
   - **Level 1 (Main):** ContentOrder.order - Manages folders + standalone chapters
   - **Level 2 (Folder):** ChapterInFolder.order - Manages chapters within each folder
   - **Level 3 (Custom):** SwapFolder.order - Custom ordering of folders
   - **Level 4 (Custom):** UserChapter.order - Custom ordering of root-level chapters

5. **Reordering Methods:**
   - **Drag-Drop:** Use `reorder-*` endpoints (efficient, individual item movements)
   - **Bulk Reorder:** Use `swap` or `swipe` endpoints (array-based, all items at once)
   - **Two-Item Swap:** Use deprecated `swap-*` endpoints (limited functionality)

6. **Cascading Deletes:**
   - Deleting a folder also deletes all ChapterInFolder entries and ContentOrder entries
   - Deleting a chapter also deletes all Exercises, ContentOrder, ChapterInFolder, Favorite, and UserChapter entries
   - Deleting removes associated custom order records

7. **Sorting:**
   - Ascending (asc) - Position 1, 2, 3... (default)
   - Descending (desc) - Reverse order

8. **Authentication & User Isolation:**
   - All endpoints require Bearer token authentication
   - userId is automatically extracted from JWT token
   - Users can only access/modify their own content
   - No need to pass userId in request body (except legacy endpoints)

9. **File Upload Limits:**
   - Single file: 50MB
   - Multiple files: 10 files max, 50MB each
   - Allowed types: JPEG, PNG, WEBP, GIF, PDF

10. **Deprecated vs Current:**
    - ⚠️ **Deprecated:** `/swap-content`, `/swap-chapters-in-folder` (limited to 2-item swaps)
    - ✅ **Current:** `/reorder-content`, `/reorder-chapters-in-folder` (drag-drop support, efficient)
    - ✅ **Current:** `/folder/swap`, `/chapter/swipe` (bulk reordering)
