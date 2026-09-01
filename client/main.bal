import ballerina/io;

public function main() returns error? {
    boolean running = true;

    while running {
        io:println("\n=== Library & Resource Management - Client ===");
        io:println("1. View all assets (Global View)");
        io:println("2. Add a new asset");
        io:println("3. View assets by institution/site (Campus View)");
        io:println("4. Loan an asset / book a room");
        io:println("5. Overdue dashboard");
        io:println("6. Schedule manager");
        io:println("7. Components & work orders");
        io:println("0. Exit");
        string choice = io:readln("Select an option: ").trim();

        match choice {
            "1" => {
                check showAllAssets();
            }
            "2" => {
                check addAssetFlow();
            }
            "3" => {
                check campusViewFlow();
            }
            "4" => {
                check loanOrBookFlow();
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


function addAssetFlow() returns error? {
    string tag = io:readln("Asset tag: ").trim();
    string name = io:readln("Name: ").trim();
    string institution = io:readln("Institution: ").trim();
    string site = io:readln("Site/Campus: ").trim();
    string dateAcquired = io:readln("Date acquired (YYYY-MM-DD): ").trim();

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


function campusViewFlow() returns error? {
    string institution = io:readln("Institution: ").trim();
    string site = io:readln("Site/Campus (leave blank for all sites): ").trim();

    Asset[]|error result;
    if site.length() == 0 {
        result = getAssetsByInstitution(institution);
    } else {
        result = getAssetsByInstitutionAndSite(institution, site);
    }

    if result is error {
        io:println("Failed to fetch assets: ", result.message());
        return;
    }
    if result.length() == 0 {
        io:println("No assets found for that institution/site.");
        return;
    }
    foreach Asset a in result {
        io:println(a.assetTag, " | ", a.name, " | ", a.institution, " - ", a.site, " | ", a.status);
    }
}


function loanOrBookFlow() returns error? {
    string tag = io:readln("Asset tag to loan/book: ").trim();

    Asset|error current = getAsset(tag);
    if current is error {
        io:println("Could not find that asset: ", current.message());
        return;
    }

    string statusChoice = io:readln("Set status to (1) LOANED_OUT or (2) OCCUPIED: ").trim();
    AssetStatus newStatus = statusChoice == "2" ? OCCUPIED : LOANED_OUT;

    Asset updated = current;
    updated.status = newStatus;

    Asset|error result = updateAsset(tag, updated);
    if result is Asset {
        io:println("Updated ", result.assetTag, " to status ", result.status);
    } else {
        io:println("Error updating asset: ", result.message());
    }
}


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


function scheduleManagerFlow() returns error? {
    string assetTag = io:readln("Asset tag: ").trim();
    string action = io:readln("Add or remove a schedule? (add/remove): ").trim();

    if action == "add" {
        string scheduleId = io:readln("Schedule ID: ").trim();
        string scheduleType = io:readln("Type (MAINTENANCE/BOOKING/SERVICING): ").trim();
        string dueDate = io:readln("Due date (YYYY-MM-DD): ").trim();
        string description = io:readln("Description: ").trim();

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
        string scheduleId = io:readln("Schedule ID to remove: ").trim();

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
        string choice = io:readln("Select an option: ").trim();

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
    string assetTag = io:readln("Asset tag: ").trim();
    Asset|error result = getAsset(assetTag);
    if result is error {
        io:println("Failed to fetch asset: ", result.message());
        return;
    }
    printAssetDetails(result);
}

function addComponentFlow() returns error? {
    string assetTag = io:readln("Asset tag: ").trim();
    string name = io:readln("Component name: ").trim();
    string description = io:readln("Description (optional): ").trim();

    Component newComponent = {
        compId: "",
        name: name
    };
    if description.length() > 0 {
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
    string assetTag = io:readln("Asset tag: ").trim();
    string compId = io:readln("Component ID: ").trim();

    Asset|error result = removeComponent(assetTag, compId);
    if result is Asset {
        io:println("Component removed.");
        printAssetDetails(result);
    } else {
        io:println("Error removing component: ", result.message());
    }
}

function openWorkOrderFlow() returns error? {
    string assetTag = io:readln("Asset tag: ").trim();
    string description = io:readln("Work order description: ").trim();

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
    string assetTag = io:readln("Asset tag: ").trim();
    string orderId = io:readln("Work order ID: ").trim();
    string status = io:readln("New status (OPEN / IN_PROGRESS / CLOSED): ").trim();
    string description = io:readln("New description (leave blank to keep current): ").trim();

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
    string assetTag = io:readln("Asset tag: ").trim();
    string orderId = io:readln("Work order ID: ").trim();

    Asset|error result = deleteWorkOrder(assetTag, orderId);
    if result is Asset {
        io:println("Work order removed.");
        printAssetDetails(result);
    } else {
        io:println("Error removing work order: ", result.message());
    }
}

function addTaskFlow() returns error? {
    string assetTag = io:readln("Asset tag: ").trim();
    string orderId = io:readln("Work order ID: ").trim();
    string description = io:readln("Task description: ").trim();

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
