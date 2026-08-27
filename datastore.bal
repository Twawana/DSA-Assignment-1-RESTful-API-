// All assets stored here, keyed by their unique assetTag
public map<Asset> assetStore = {};

// All institutions stored here, keyed by their unique institutionId
public map<Institution> institutionStore = {};



// Check if an asset exists
public function assetExists(string assetTag) returns boolean {
    return assetStore.hasKey(assetTag);
}

// Get an asset or return an error if not found
public function getAssetOrError(string assetTag) returns Asset|error {
    if assetStore.hasKey(assetTag) {
        return assetStore.get(assetTag);
    }
    return error("Asset not found: " + assetTag);
}

// Check if an institution exists
public function institutionExists(string institutionId) returns boolean {
    return institutionStore.hasKey(institutionId);
}

// Get an institution or return an error if not found
public function getInstitutionOrError(string institutionId) returns Institution|error {
    if institutionStore.hasKey(institutionId) {
        return institutionStore.get(institutionId);
    }
    return error("Institution not found: " + institutionId);
}