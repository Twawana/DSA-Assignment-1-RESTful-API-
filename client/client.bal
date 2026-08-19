import ballerina/http;

configurable string apiBaseUrl = "http://localhost:8080/api";

final http:Client apiClient = check new (apiBaseUrl);

# Fetch every asset from the API (Global View).
# + return - all assets, or an error if the call failed
public function getAllAssets() returns Asset[]|error {
    Asset[] assets = check apiClient->get("/assets");
    return assets;
}

# Create a new asset.
# + newAsset - the asset to create
# + return - the created asset, or an error if the call failed
public function createAsset(Asset newAsset) returns Asset|error {
    Asset created = check apiClient->post("/assets", newAsset);
    return created;
}

# Fetch every asset with at least one overdue schedule.
# + return - overdue assets, or an error if the call failed
public function getOverdueAssets() returns Asset[]|error {
    Asset[] assets = check apiClient->get("/assets/overdue");
    return assets;
}

# Add a schedule to an asset.
# + assetTag - the unique asset identifier
# + newSchedule - the schedule to add
# + return - the updated asset, or an error if the call failed
public function addSchedule(string assetTag, Schedule newSchedule) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/schedules", newSchedule);
    return updated;
}

# Remove a schedule from an asset.
# + assetTag - the unique asset identifier
# + scheduleId - the schedule identifier to remove
# + return - the updated asset, or an error if the call failed
public function removeSchedule(string assetTag, string scheduleId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    return updated;
}