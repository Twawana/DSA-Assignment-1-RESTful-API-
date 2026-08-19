import ballerina/io;

public function main() returns error? {
    boolean running = true;

    while running {
        io:println("\n=== Library & Resource Management - Client ===");
        io:println("1. View all assets (Global View)");
        io:println("2. Add a new asset");
        io:println("3. View assets by institution/site (Campus View)");     // TODO
        io:println("4. Loan an asset / book a room");                       // TODO
        io:println("5. Overdue dashboard");                                 // TODO
        io:println("6. Schedule manager");                                  // TODO
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

