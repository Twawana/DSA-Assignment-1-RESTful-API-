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

// -----------------------------------------------------------------------
// TODO (team): add a wrapper function per remaining endpoint, following
// the exact pattern above (call apiClient-> with the right verb/path,
// `check` it, return the typed result). You'll need one for each of:
//
//   - getAsset(assetTag)                        -> GET /assets/{tag}
//   - updateAsset(assetTag, asset)               -> PUT /assets/{tag}
//   - deleteAsset(assetTag)                      -> DELETE /assets/{tag}
//   - getAssetsByInstitution(institution)         -> GET /assets/institution/{institution}
//   - getAssetsByInstitutionAndSite(inst, site)   -> GET /assets/institution/{institution}/site/{site}
//   - getOverdueAssets()                          -> GET /assets/overdue
//   - addSchedule(assetTag, schedule)             -> POST /assets/{tag}/schedules
//   - removeSchedule(assetTag, scheduleId)        -> DELETE /assets/{tag}/schedules/{id}
//   - openWorkOrder(assetTag, workOrder)          -> POST /assets/{tag}/workorders
//   - etc.
// -----------------------------------------------------------------------
