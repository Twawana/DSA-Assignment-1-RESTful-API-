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

public function getAsset(string assetTag) returns Asset|error {
    Asset result = check apiClient->get("/assets/" + assetTag);
    return result;
}

public function updateAsset(string assetTag, Asset updatedAsset) returns Asset|error {
    Asset result = check apiClient->put("/assets/" + assetTag, updatedAsset);
    return result;
}

public function getAssetsByInstitution(string institution) returns Asset[]|error {
    Asset[] result = check apiClient->get("/assets/institution/" + institution);
    return result;
}

public function getAssetsByInstitutionAndSite(string institution, string site) returns Asset[]|error {
    Asset[] result = check apiClient->get("/assets/institution/" + institution + "/site/" + site);
    return result;
}

public function getOverdueAssets() returns Asset[]|error {
    Asset[] result = check apiClient->get("/assets/overdue");
    return result;
}

public function addSchedule(string assetTag, Schedule newSchedule) returns Asset|error {
    Asset result = check apiClient->post("/assets/" + assetTag + "/schedules", newSchedule);
    return result;
}

public function removeSchedule(string assetTag, string scheduleId) returns Asset|error {
    Asset result = check apiClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    return result;
}  