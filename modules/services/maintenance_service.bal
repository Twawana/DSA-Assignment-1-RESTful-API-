
import ballerina/time;
import question1_full.models;

// Reuses the `assets` table declared in schedule_service.bal — same module, no import needed.

service /library on scheduleListener {

    // Overdue dashboard — any asset with at least one schedule whose dueDate has passed
    resource function get assets/overdue() returns models:Asset[] {
        string today = time:utcToString(time:utcNow()).substring(0, 10); // "YYYY-MM-DD"

        models:Asset[] overdueAssets = [];
        foreach models:Asset asset in assets {
            foreach models:Schedule sch in asset.schedules {
                if sch.dueDate < today {
                    overdueAssets.push(asset);
                    break;
                }
            }
        }
        return overdueAssets;
    }
}