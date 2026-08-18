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
                check campusViewFlow();
            }
            "4" => {
                check loanOrBookFlow();
            }
            "5" => {
                check overdueDashboardFlow();
            }
            "6" => {
                check scheduleManagerFlow();
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

function campusViewFlow() returns error? {
    string institution = io:readln("Institution: ");
    string site = io:readln("Site/Campus (leave blank for all sites): ");

    Asset[]|error result;
    if site.trim() == "" {
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
    string tag = io:readln("Asset tag to loan/book: ");

    Asset|error current = getAsset(tag);
    if current is error {
        io:println("Could not find that asset: ", current.message());
        return;
    }

    string statusChoice = io:readln("Set status to (1) LOANED_OUT or (2) OCCUPIED: ");
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

function overdueDashboardFlow() returns error? {
    Asset[]|error result = getOverdueAssets();
    if result is error {
        io:println("Failed to fetch overdue assets: ", result.message());
        return;
    }
    if result.length() == 0 {
        io:println("Nothing overdue right now.");
        return;
    }
    foreach Asset a in result {
        io:println(a.assetTag, " | ", a.name, " | ", a.institution, " - ", a.site);
    }
}

function scheduleManagerFlow() returns error? {
    string tag = io:readln("Asset tag: ");
    string action = io:readln("(1) Add schedule or (2) Remove schedule: ");

    if action == "2" {
        string scheduleId = io:readln("Schedule ID to remove: ");
        Asset|error removeResult = removeSchedule(tag, scheduleId);
        if removeResult is Asset {
            io:println("Removed. Remaining schedules: ", removeResult.schedules.length());
        } else {
            io:println("Error removing schedule: ", removeResult.message());
        }
        return;
    }

    string scheduleId = io:readln("New schedule ID: ");
    string scheduleType = io:readln("Type (MAINTENANCE/BOOKING/SERVICING): ");
    string dueDate = io:readln("Due date (YYYY-MM-DD): ");

    Schedule newSchedule = {
        scheduleId: scheduleId,
        'type: scheduleType,
        dueDate: dueDate
    };

    Asset|error addResult = addSchedule(tag, newSchedule);
    if addResult is Asset {
        io:println("Schedule added. Total schedules: ", addResult.schedules.length());
    } else {
        io:println("Error adding schedule: ", addResult.message());
    }
}