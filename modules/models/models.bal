public type Schedule record {
    string scheduleId;
    string scheduleType;
    string dueDate;
    string description;
};

public type Component record {
    string compId;
    string name;
    string description;
};

public type Task record {
    string taskId;
    string description;
    string status = "PENDING";
};

public type WorkOrder record {
    string orderId;
    string status;
    string description;
    Task[] tasks = [];
};

public type Asset record {
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
};