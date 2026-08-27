// ENUMS - defining Fixed sets of values, as status can only be one of the options
//prevents typos like available or maintainance

public enum AssetStatus {
    AVAILABLE,
    LOANED_OUT,
    OCCUPIED,
    UNDER_MAINTENANCE,
    DISPOSED
}


// RECORDS - Data structures

// The main asset record - every item in the system follows this shape
public type Asset record {|
    string assetTag;           // Unique identifier (e.g., "LAP-001")
    string name;               // Display name (e.g., "Dell XPS 13")
    string description;        // Detailed description
    string institution;        // Which institution owns it (e.g., "UNAM")
    string site;               // Which campus/site (e.g., "Main Campus")
    string acquiredDate;       // When purchased (e.g., "2025-01-15")
    AssetStatus status;        // AVAILABLE, LOANED_OUT, etc.

    // Optional fields (not all assets have these)
    Component[]? components?;  // List of parts (e.g., 3D printer parts)
    Schedule[]? schedules?;    // Maintenance/booking dates
    WorkOrder[]? workOrders?;  // Repair/fault reports
|};

// A component/part that makes up an asset
public type Component record {
    string compId;             // Unique ID for this component
    string name;               // Component name (e.g., "Stepper Motor")
    string description;        // Component details
};

// A schedule tied to an asset (maintenance, booking, servicing)
public type Schedule record {
    string scheduleId;         // Unique ID for this schedule
    string scheduleType;       // "MAINTENANCE", "SERVICING", "BOOKING"
    string dueDate;            // When it's due (e.g., "2026-09-01")
    string? description;       // Optional details
};

// A work order (fault/repair report)
public type WorkOrder record {
    string orderId;            // Unique ID for this work order
    string description;        // What's wrong
    string status;             // "OPEN", "IN_PROGRESS", "CLOSED"
    string createdDate;        // When it was opened
    Task[]? tasks;             // Subtasks under this work order
};

// A subtask inside a work order
public type Task record {
    string taskId;             // Unique ID for this task
    string description;        // e.g., "Replace screen"
    string status;             // "PENDING" or "COMPLETED"
};

// An institution (university/campus)
public type Institution record {
    string institutionId;      // Unique ID
    string name;               // Full name
    string? address?;          // Optional address
};

// Request type for updating an asset (Task 3)
// Note: All fields are optional so clients can update just what they need
public type AssetUpdateRequest record {|
    string name?;
    string description?;
    string institution?;
    string site?;
    string acquiredDate?;
    AssetStatus status?;
|};