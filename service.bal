import ballerina/http;

service /api on new http:Listener(8080) {

    resource function put assets/[string assetTag](@http:Payload AssetUpdateRequest req)
            returns Asset|http:NotFound|http:BadRequest {

        if !assetStore.hasKey(assetTag) {
            return <http:NotFound>{body: {message: "Asset with tag '" + assetTag + "' not found"}};
        }

        Asset existing = assetStore.get(assetTag);

        if req?.name != () {
            existing.name = <string>req?.name;
        }
        if req?.description != () {
            existing.description = <string>req?.description;
        }
        if req?.institution != () {
            existing.institution = <string>req?.institution;
        }
        if req?.site != () {
            existing.site = <string>req?.site;
        }
        if req?.acquiredDate != () {
            existing.acquiredDate = <string>req?.acquiredDate;
        }
        if req?.status != () {
            existing.status = <AssetStatus>req?.status;
        }

        assetStore[assetTag] = existing;
        return existing;
    }

    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(assetTag) {
            return <http:NotFound>{body: {message: "Asset with tag '" + assetTag + "' not found"}};
        }

        _ = assetStore.remove(assetTag);
        return <http:Ok>{body: {message: "Asset deleted successfully"}};
    }

    resource function get assets() returns Asset[] {
        return assetStore.toArray();
    }

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        if assetStore.hasKey(assetTag) {
            return assetStore.get(assetTag);
        }
        return <http:NotFound>{body: {message: "Asset with tag '" + assetTag + "' not found"}};
    }

    resource function post assets(@http:Payload Asset asset) returns Asset|http:Conflict|http:BadRequest {
        if asset.assetTag == "" {
            return <http:BadRequest>{body: {message: "assetTag is required"}};
        }

        if assetStore.hasKey(asset.assetTag) {
            return <http:Conflict>{body: {message: "Asset with tag '" + asset.assetTag + "' already exists"}};
        }

        Asset newAsset = {
            assetTag: asset.assetTag,
            name: asset.name,
            description: asset.description,
            institution: asset.institution,
            site: asset.site,
            acquiredDate: asset.acquiredDate,
            status: asset.status,
            components: asset?.components is Component[] ? asset?.components : [],
            schedules: asset?.schedules is Schedule[] ? asset?.schedules : [],
            workOrders: asset?.workOrders is WorkOrder[] ? asset?.workOrders : []
        };

        assetStore[asset.assetTag] = newAsset;
        return newAsset;
    }

    resource function post assets/[string assetTag]/schedules() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Schedule management not implemented yet"}};
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Schedule deletion not implemented yet"}};
    }

    resource function get assets/overdue() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Overdue check not implemented yet"}};
    }

    resource function post assets/[string assetTag]/components() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Component management not implemented yet"}};
    }

    resource function delete assets/[string assetTag]/components/[string compId]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Component deletion not implemented yet"}};
    }

    resource function post assets/[string assetTag]/workorders() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Work order management not implemented yet"}};
    }

    resource function put assets/[string assetTag]/workorders/[string orderId]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Work order update not implemented yet"}};
    }

    resource function delete assets/[string assetTag]/workorders/[string orderId]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Work order deletion not implemented yet"}};
    }

    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Task management not implemented yet"}};
    }

    resource function post institutions() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Institution creation not implemented yet"}};
    }

    resource function delete institutions/[string institutionId]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Institution deletion not implemented yet"}};
    }

    resource function get assets/institution/[string institution]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Institution filtering not implemented yet"}};
    }

    resource function get assets/institution/[string institution]/site/[string site]() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Institution+site filtering not implemented yet"}};
    }

    resource function get institutions() returns http:NotImplemented {
        return <http:NotImplemented>{body: {message: "Get institutions not implemented yet"}};
    }
}