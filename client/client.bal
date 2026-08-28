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

# Look up a single asset by its tag.
# + assetTag - the unique asset identifier
# + return - the asset, or an error if the call failed
public function getAsset(string assetTag) returns Asset|error {
    Asset asset = check apiClient->get("/assets/" + assetTag);
    return asset;
}

# Add a physical component to an asset.
# + assetTag - the unique asset identifier
# + newComponent - the component to add
# + return - the updated asset, or an error if the call failed
public function addComponent(string assetTag, Component newComponent) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/components", newComponent);
    return updated;
}

# Remove a component from an asset by compId.
# + assetTag - the unique asset identifier
# + compId - the component identifier to remove
# + return - the updated asset, or an error if the call failed
public function removeComponent(string assetTag, string compId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/components/" + compId);
    return updated;
}

# Open a new work order on an asset.
# + assetTag - the unique asset identifier
# + newWorkOrder - the work order to open
# + return - the updated asset, or an error if the call failed
public function openWorkOrder(string assetTag, WorkOrder newWorkOrder) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/workorders", newWorkOrder);
    return updated;
}

# Update an existing work order's status/description.
# + assetTag - the unique asset identifier
# + orderId - the work order identifier
# + updatedWorkOrder - the new work order details
# + return - the updated asset, or an error if the call failed
public function updateWorkOrder(string assetTag, string orderId, WorkOrder updatedWorkOrder) returns Asset|error {
    Asset updated = check apiClient->put("/assets/" + assetTag + "/workorders/" + orderId, updatedWorkOrder);
    return updated;
}

# Close/remove a work order from an asset.
# + assetTag - the unique asset identifier
# + orderId - the work order identifier
# + return - the updated asset, or an error if the call failed
public function deleteWorkOrder(string assetTag, string orderId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/workorders/" + orderId);
    return updated;
}

# Add a sub-task underneath an existing work order.
# + assetTag - the unique asset identifier
# + orderId - the work order identifier
# + newTask - the sub-task to add
# + return - the updated asset, or an error if the call failed
public function addTask(string assetTag, string orderId, Task newTask) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/workorders/" + orderId + "/tasks", newTask);
    return updated;
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

// -----------------------------------------------------------------------
// TODO (team): add a wrapper function per remaining endpoint, following
// the exact pattern above (call apiClient-> with the right verb/path,
// `check` it, return the typed result). You'll need one for each of:
//
//   - updateAsset(assetTag, asset)               -> PUT /assets/{tag}
//   - deleteAsset(assetTag)                      -> DELETE /assets/{tag}
//   - getAssetsByInstitution(institution)         -> GET /assets/institution/{institution}
//   - getAssetsByInstitutionAndSite(inst, site)   -> GET /assets/institution/{institution}/site/{site}
// -----------------------------------------------------------------------
