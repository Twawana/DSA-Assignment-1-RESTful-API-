import ballerina/http;

configurable string apiBaseUrl = "http://localhost:8080/api";

final http:Client apiClient = check new (apiBaseUrl);


public function getAllAssets() returns Asset[]|error {
    Asset[] assets = check apiClient->get("/assets");
    return assets;
}


public function createAsset(Asset newAsset) returns Asset|error {
    Asset created = check apiClient->post("/assets", newAsset);
    return created;
}


public function getAsset(string assetTag) returns Asset|error {
    Asset asset = check apiClient->get("/assets/" + assetTag);
    return asset;
}


public function updateAsset(string assetTag, Asset updatedAsset) returns Asset|error {
    Asset result = check apiClient->put("/assets/" + assetTag, updatedAsset);
    return result;
}


public function deleteAsset(string assetTag) returns error? {
    _ = check apiClient->delete("/assets/" + assetTag, targetType = http:Response);
}


public function getAssetsByInstitution(string institution) returns Asset[]|error {
    Asset[] result = check apiClient->get("/assets/institution/" + institution);
    return result;
}


public function getAssetsByInstitutionAndSite(string institution, string site) returns Asset[]|error {
    Asset[] result = check apiClient->get("/assets/institution/" + institution + "/site/" + site);
    return result;
}


public function addComponent(string assetTag, Component newComponent) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/components", newComponent);
    return updated;
}


public function removeComponent(string assetTag, string compId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/components/" + compId);
    return updated;
}


public function openWorkOrder(string assetTag, WorkOrder newWorkOrder) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/workorders", newWorkOrder);
    return updated;
}


public function updateWorkOrder(string assetTag, string orderId, WorkOrder updatedWorkOrder) returns Asset|error {
    Asset updated = check apiClient->put("/assets/" + assetTag + "/workorders/" + orderId, updatedWorkOrder);
    return updated;
}


public function deleteWorkOrder(string assetTag, string orderId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/workorders/" + orderId);
    return updated;
}


public function addTask(string assetTag, string orderId, Task newTask) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/workorders/" + orderId + "/tasks", newTask);
    return updated;
}


public function getOverdueAssets() returns Asset[]|error {
    Asset[] assets = check apiClient->get("/assets/overdue");
    return assets;
}


public function addSchedule(string assetTag, Schedule newSchedule) returns Asset|error {
    Asset updated = check apiClient->post("/assets/" + assetTag + "/schedules", newSchedule);
    return updated;
}


public function removeSchedule(string assetTag, string scheduleId) returns Asset|error {
    Asset updated = check apiClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    return updated;
}

