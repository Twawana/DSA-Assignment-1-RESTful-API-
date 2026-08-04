import ballerina/http;

public type Asset record {
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
};

listener http:Listener assetListener = new(8080);

service /library on assetListener {

    final table<Asset> key(assetTag) assets = table [];

    resource function get assets() returns Asset[] {
        return self.assets.toArray();
    }

    resource function post assets(Asset asset) returns Asset|http:Conflict {
        if self.assets.hasKey(asset.assetTag) {
            return http:CONFLICT;
        }

        self.assets.add(asset);
        return asset;
    }
}