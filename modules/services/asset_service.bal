import ballerina/http;
import question1_full.models;

listener http:Listener assetListener = new(8080);

service /library on assetListener {

    final table<models:Asset> key(assetTag) assets = table [];

    resource function get assets() returns models:Asset[] {
        return self.assets.toArray();
    }

    resource function post assets(models:Asset asset)
            returns models:Asset|http:Conflict {

        if self.assets.hasKey(asset.assetTag) {
            return http:CONFLICT;
        }

        self.assets.add(asset);
        return asset;
    }
}