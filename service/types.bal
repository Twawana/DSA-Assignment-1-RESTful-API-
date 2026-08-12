// Core data model for the Library and Resource Management System.
// Mirrors the sample payload in the assignment brief (Section 4).

// AVAILABLE          - ready to be loaned/booked
// LOANED_OUT         - a book/laptop/thin client currently out with a user
// OCCUPIED           - a room/lab currently in use
// UNDER_MAINTENANCE  - temporarily out of service
// DISPOSED           - retired, no longer in circulation
public enum AssetStatus {
    AVAILABLE,
    LOANED_OUT,
    OCCUPIED,
    UNDER_MAINTENANCE,
    DISPOSED
}

public type Component record {|
    string compId;
    string name;
    string description?;
|};

public type Schedule record {|
    string scheduleId;
    string 'type; // e.g. "MAINTENANCE", "BOOKING", "SERVICING"
    string dueDate; // ISO date, e.g. "2026-09-01"
    string description?;
|};

public type Task record {|
    string taskId;
    string description;
    boolean completed = false;
|};

public type WorkOrder record {|
    string orderId;
    string status; // e.g. "OPEN", "IN_PROGRESS", "CLOSED"
    string description;
    Task[] tasks = [];
|};

public type Asset record {|
    string assetTag; // unique identifier - the datastore key
    string name;
    string description?;
    string institution;
    string site;
    AssetStatus status = AVAILABLE;
    string dateAcquired; // ISO date, e.g. "2024-03-10"
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};

public type Institution record {|
    string institutionId;
    string name;
    string[] sites = [];
|};

// Generic error body returned by the API on failure.
public type ErrorDetail record {|
    string message;
    string errorCode;
|};
