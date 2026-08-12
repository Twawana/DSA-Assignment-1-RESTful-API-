// In-memory data store for the service.
//
// TODO (team, optional): if you'd rather use a `table` keyed on assetTag
// instead of a `map<Asset>`, this is the only file that needs to change -
// everything in service.bal just needs assetTag -> Asset lookups.

# In-memory store of assets, keyed by assetTag (the unique identifier).
map<Asset> assetStore = {};

# In-memory store of institutions, keyed by institutionId.
map<Institution> institutionStore = {};
