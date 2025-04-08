Entity Relationship Overview
This application manages image/video annotation projects using a well-structured SQLite schema.

🧩 Entity Relationships Recap
    Projects → contain multiple Datasets

    Datasets → contain many MediaItems (images/videos)

    Projects → define a set of Labels

    MediaItems → contain many Annotations

    Annotations → link MediaItems to Labels


🔗 Visual Diagram (Text-based)
Projects ──────┐
               │
               ▼
           Datasets ────────┐
                            ▼
                      MediaItems ──────────────┐
                                              ▼
                                        Annotations ───────► Labels


📋 Table Responsibilities
    Table	Description
    users	Stores user profile and preferences
    projects	Root-level entities, each with its own datasets and labels
    datasets	Groups of media items within a project
    media_items	Images or videos to be annotated
    labels	Predefined tags assigned to regions in media (project-specific)
    annotations	Links a media item to a label with spatial coordinates (bounding box)


🧠 Query Examples
-- Get all annotations for a media item
SELECT * FROM annotations WHERE media_item_id = ?;

-- Get all labels used in a media item
SELECT labels.*
FROM annotations
JOIN labels ON annotations.label_id = labels.id
WHERE annotations.media_item_id = ?;

-- Get all media items tagged with a specific label
SELECT media_items.*
FROM annotations
JOIN media_items ON annotations.media_item_id = media_items.id
WHERE annotations.label_id = ?;
