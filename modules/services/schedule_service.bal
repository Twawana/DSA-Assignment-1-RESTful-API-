import ballerina/http;
import question1_full.models;

// TEMPORARY STUB — remove this once storage.bal exposes the real shared table.
// Swap `assets` here for the shared one and nothing else below needs to change.
final table<models:Asset> key(assetTag) assets = table [];

listener http:Listener scheduleListener = new (8081);

service /library on scheduleListener {

    // Add a schedule to an asset
    resource function post assets/[string assetTag]/schedules(models:Schedule schedule)
            returns models:Schedule|http:NotFound|http:Conflict {

        models:Asset? asset = assets[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }

        foreach models:Schedule existing in asset.schedules {
            if existing.scheduleId == schedule.scheduleId {
                return http:CONFLICT;
            }
        }

        asset.schedules.push(schedule);
        return schedule;
    }

    // Remove a schedule from an asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]()
            returns http:Ok|http:NotFound {

        models:Asset? asset = assets[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }

        int? indexToRemove = ();
        foreach int i in 0 ..< asset.schedules.length() {
            if asset.schedules[i].scheduleId == scheduleId {
                indexToRemove = i;
            }
        }

        if indexToRemove is int {
            _ = asset.schedules.remove(indexToRemove);
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    // View all schedules for one asset
    resource function get assets/[string assetTag]/schedules()
            returns models:Schedule[]|http:NotFound {

        models:Asset? asset = assets[assetTag];
        if asset is () {
            return http:NOT_FOUND;
        }
        return asset.schedules;
    }
}