import ballerina/io;

public function main() returns error? {
    boolean running = true;

    while running {
        io:println("\n=== Library & Resource Management - Client ===");
        io:println("1. View all assets (Global View)");
        io:println("2. Add a new asset");
        io:println("3. View assets by institution/site (Campus View)");     // TODO
        io:println("4. Loan an asset / book a room");                       // TODO
        io:println("5. Overdue dashboard");
        io:println("6. Schedule manager");
        io:println("7. Components & work orders");
        io:println("0. Exit");
        string choice = io:readln("Select an option: ");

        match choice {
            "1" => {
                check showAllAssets();
            }
            "2" => {
                check addAssetFlow();
            }
            "3" => {
                io:println("TODO: prompt for institution/site and call getAssetsByInstitution(...)");
            }
            "4" => {
                io:println("TODO: implement loaning/booking flow");
            }
            "5" => {
                check showOverdueDashboard();
            }
            "6" => {
                check scheduleManagerFlow();
            }
            "7" => {
                check componentsAndWorkOrdersMenu();
            }
            "0" => {
                running = false;
            }
            _ => {
                io:println("Invalid option, try again.");
            }
        }
    }
    return;
}

# Worked example: fetches and prints every asset.
function showAllAssets() returns error? {
    Asset[]|error result = getAllAssets();
    if result is error {
        io:println("Failed to fetch assets: ", result.message());
        return;
    }
    if result.length() == 0 {
        io:println("No assets found.");
        return;
    }
    foreach Asset a in result {
        io:println(a.assetTag, " | ", a.name, " | ", a.institution, " - ", a.site, " | ", a.status);
    }
}

# Worked example: prompts for the required fields and creates an asset.
function addAssetFlow() returns error? {
    string tag = io:readln("Asset tag: ");
    string name = io:readln("Name: ");
    string institution = io:readln("Institution: ");
    string site = io:readln("Site/Campus: ");
    string dateAcquired = io:readln("Date acquired (YYYY-MM-DD): ");

    Asset newAsset = {
        assetTag: tag,
        name: name,
        institution: institution,
        site: site,
        dateAcquired: dateAcquired
    };

    Asset|error result = createAsset(newAsset);
    if result is Asset {
        io:println("Created: ", result.assetTag);
    } else {
        io:println("Error creating asset: ", result.message());
    }
}

# Fetches and prints every asset with an overdue schedule.
function showOverdueDashboard() returns error? {
    Asset[]|error result = getOverdueAssets();
    if result is error {
        io:println("Failed to fetch overdue assets: ", result.message());
        return;
    }
    if result.length() == 0 {
        io:println("No overdue assets. Everything is up to date.");
        return;
    }
    io:println("\n--- OVERDUE ASSETS ---");
    foreach Asset a in result {
        io:println(a.assetTag, " | ", a.name, " | ", a.institution, " - ", a.site);
        foreach Schedule sch in a.schedules {
            io:println("    -> ", sch.scheduleId, " (", sch.'type, ") due ", sch.dueDate, " - ", sch.description ?: "");
        }
    }
}

# Lets the user add or remove a schedule on a given asset.
function scheduleManagerFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string action = io:readln("Add or remove a schedule? (add/remove): ");

    if action == "add" {
        string scheduleId = io:readln("Schedule ID: ");
        string scheduleType = io:readln("Type (MAINTENANCE/BOOKING/SERVICING): ");
        string dueDate = io:readln("Due date (YYYY-MM-DD): ");
        string description = io:readln("Description: ");

        Schedule newSchedule = {
            scheduleId: scheduleId,
            'type: scheduleType,
            dueDate: dueDate,
            description: description
        };

        Asset|error result = addSchedule(assetTag, newSchedule);
        if result is Asset {
            io:println("Schedule added. ", assetTag, " now has ", result.schedules.length(), " schedule(s).");
        } else {
            io:println("Error adding schedule: ", result.message());
        }
    } else if action == "remove" {
        string scheduleId = io:readln("Schedule ID to remove: ");

        Asset|error result = removeSchedule(assetTag, scheduleId);
        if result is Asset {
            io:println("Schedule removed. ", assetTag, " now has ", result.schedules.length(), " schedule(s).");
        } else {
            io:println("Error removing schedule: ", result.message());
        }
    } else {
        io:println("Invalid option, try 'add' or 'remove'.");
    }
}

# Submenu for nested components, work orders, and tasks on an asset.
function componentsAndWorkOrdersMenu() returns error? {
    boolean inMenu = true;
    while inMenu {
        io:println("\n--- Components & work orders ---");
        io:println("1. View asset (components, work orders, tasks)");
        io:println("2. Add a component");
        io:println("3. Remove a component");
        io:println("4. Open a work order");
        io:println("5. Update a work order status/description");
        io:println("6. Remove a work order");
        io:println("7. Add a task to a work order");
        io:println("0. Back");
        string choice = io:readln("Select an option: ");

        match choice {
            "1" => {
                check viewAssetFlow();
            }
            "2" => {
                check addComponentFlow();
            }
            "3" => {
                check removeComponentFlow();
            }
            "4" => {
                check openWorkOrderFlow();
            }
            "5" => {
                check updateWorkOrderFlow();
            }
            "6" => {
                check removeWorkOrderFlow();
            }
            "7" => {
                check addTaskFlow();
            }
            "0" => {
                inMenu = false;
            }
            _ => {
                io:println("Invalid option, try again.");
            }
        }
    }
}

function viewAssetFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    Asset|error result = getAsset(assetTag);
    if result is error {
        io:println("Failed to fetch asset: ", result.message());
        return;
    }
    printAssetDetails(result);
}

function addComponentFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string name = io:readln("Component name: ");
    string description = io:readln("Description (optional): ");

    Component newComponent = {
        compId: "",
        name: name
    };
    if description.trim().length() > 0 {
        newComponent.description = description;
    }

    Asset|error result = addComponent(assetTag, newComponent);
    if result is Asset {
        io:println("Component added.");
        printAssetDetails(result);
    } else {
        io:println("Error adding component: ", result.message());
    }
}

function removeComponentFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string compId = io:readln("Component ID: ");

    Asset|error result = removeComponent(assetTag, compId);
    if result is Asset {
        io:println("Component removed.");
        printAssetDetails(result);
    } else {
        io:println("Error removing component: ", result.message());
    }
}

function openWorkOrderFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string description = io:readln("Work order description: ");

    WorkOrder newWorkOrder = {
        orderId: "",
        status: "",
        description: description
    };

    Asset|error result = openWorkOrder(assetTag, newWorkOrder);
    if result is Asset {
        io:println("Work order opened (status OPEN).");
        printAssetDetails(result);
    } else {
        io:println("Error opening work order: ", result.message());
    }
}

function updateWorkOrderFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string orderId = io:readln("Work order ID: ");
    string status = io:readln("New status (OPEN / IN_PROGRESS / CLOSED): ");
    string description = io:readln("New description (leave blank to keep current): ");

    WorkOrder updatedWorkOrder = {
        orderId: orderId,
        status: status,
        description: description
    };

    Asset|error result = updateWorkOrder(assetTag, orderId, updatedWorkOrder);
    if result is Asset {
        io:println("Work order updated.");
        printAssetDetails(result);
    } else {
        io:println("Error updating work order: ", result.message());
    }
}

function removeWorkOrderFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string orderId = io:readln("Work order ID: ");

    Asset|error result = deleteWorkOrder(assetTag, orderId);
    if result is Asset {
        io:println("Work order removed.");
        printAssetDetails(result);
    } else {
        io:println("Error removing work order: ", result.message());
    }
}

function addTaskFlow() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string orderId = io:readln("Work order ID: ");
    string description = io:readln("Task description: ");

    Task newTask = {
        taskId: "",
        description: description
    };

    Asset|error result = addTask(assetTag, orderId, newTask);
    if result is Asset {
        io:println("Task added.");
        printAssetDetails(result);
    } else {
        io:println("Error adding task: ", result.message());
    }
}

function printAssetDetails(Asset asset) {
    io:println(asset.assetTag, " | ", asset.name, " | ", asset.status);
    io:println("  Institution: ", asset.institution, " - ", asset.site);

    if asset.components.length() == 0 {
        io:println("  Components: (none)");
    } else {
        io:println("  Components:");
        foreach Component c in asset.components {
            string desc = c?.description ?: "";
            if desc.length() > 0 {
                io:println("    - ", c.compId, " | ", c.name, " | ", desc);
            } else {
                io:println("    - ", c.compId, " | ", c.name);
            }
        }
    }

    if asset.workOrders.length() == 0 {
        io:println("  Work orders: (none)");
    } else {
        io:println("  Work orders:");
        foreach WorkOrder wo in asset.workOrders {
            io:println("    - ", wo.orderId, " | ", wo.status, " | ", wo.description);
            foreach Task t in wo.tasks {
                string done = t.completed ? "done" : "open";
                io:println("        task ", t.taskId, " | ", t.description, " | ", done);
            }
        }
    }
}
